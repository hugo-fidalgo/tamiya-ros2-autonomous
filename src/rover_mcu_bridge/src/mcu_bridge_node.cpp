#include "rclcpp/rclcpp.hpp"
#include "geometry_msgs/msg/twist.hpp"
#include <sstream>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>

class McuBridgeNode : public rclcpp::Node 
{
    public:
        // Constructor
        McuBridgeNode() : Node("mcu_bridge") 
        {
            // Initialize the subscriber
            subscription_ = this->create_subscription<geometry_msgs::msg::Twist>(
                "cmd_vel", 10, std::bind(&McuBridgeNode::cmd_vel_callback, this, std::placeholders::_1));

            RCLCPP_INFO(this->get_logger(), "MCU Bridge Initialized. Listening to /cmd_vel...");

            serial_fd_ = open("/dev/arduino_mcu", O_RDWR | O_NOCTTY | O_NDELAY);

            if (serial_fd_ < 0) 
            {
                RCLCPP_ERROR(this->get_logger(), "Failed to open serial port /dev/arduino_mcu! Error: %s", strerror(errno));
            }
            else
            {
                RCLCPP_INFO(this->get_logger(), "Successfully opened serial port /dev/arduino_mcu.");

                // Configure Serial Port Parameters
                configure_serial_port();
            }
        }

        // Destructor 
        ~McuBridgeNode() 
        {
            if (serial_fd_ >= 0)
            {
                close(serial_fd_);
                RCLCPP_INFO(this->get_logger(), "Closed serial port /dev/arduino_mcu.");
            }
        }

    private:
        void configure_serial_port() 
        {
            struct termios tty;

            // Read current serial attributes
            if (tcgetattr(serial_fd_, &tty) != 0)
            {
                RCLCPP_ERROR(this->get_logger(), "Error from tcgetattr: %s", strerror(errno));
                return;
            }

            // Set Baud Rate to 115200
            cfsetospeed(&tty, B115200);
            cfsetispeed(&tty, B115200);

            // Control modes (8N1 standard)
            tty.c_cflag &= ~PARENB; // Clear parity bit (no parity)
            tty.c_cflag &= ~CSTOPB; // Clear stop field (1 stop bit)
            tty.c_cflag &= ~CSIZE; // Clear size bits
            tty.c_cflag |= CS8; // Set 8 data bits

            tty.c_cflag &= ~CRTSCTS; // Disable hardware flow control (RTS/CTS)
            tty.c_cflag |= CREAD | CLOCAL; // Turn on Read & ignore control lines (Local line)

            // Raw input/output processinhg mode (disables cannonical terminal translation)
            tty.c_lflag &= ~ICANON;
            tty.c_lflag &= ~ECHO;
            tty.c_lflag &= ~ECHOE;
            tty.c_lflag &= ~ISIG;

            tty.c_iflag &= ~(IXON | IXOFF | IXANY); // Disable software flow control
            tty.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL); // Disable special handling of input bytes

            tty.c_oflag &= ~OPOST;
            tty.c_oflag &= ~ONLCR;

            // Apply the configured settings
            if (tcsetattr(serial_fd_, TCSANOW, &tty) != 0) 
            {
                RCLCPP_ERROR(this->get_logger(), "Error from tcsetattr: %s", strerror(errno));
            }
        }
        
        void cmd_vel_callback(const geometry_msgs::msg::Twist::SharedPtr msg) const 
        {
            double linear_v = msg->linear.x; // Forward/Reverse velocity (m/s)
            double angular_w = msg->angular.z * -1.0; // Steering rotation (rad/s)

            // Calibration Constants
            const double MAX_INPUT_LINEAR_VEL = 5.0; // m/s 
            const double MAX_INPUT_ANGULAR_VEL = 1.0; // rad/s
            const int PWM_CENTER = 1500; // us
            const int PWM_MAX_DEVIATION = 500; // Maximum offset from center (1000 to 2000 us) 

            // Map linear velocity (-2.0 to 2.0 m/s assumed max) to PWM (1000 to 2000 us, 1500 is neutral)
            // Using a simple linear scaling factor:
            double linear_scale = PWM_MAX_DEVIATION / MAX_INPUT_LINEAR_VEL;
            int throttle_pwm = static_cast<int>(PWM_CENTER + (linear_v * linear_scale));

            // Map angular velocity to steering servo PWM (1000 to 2000 us, 1500 is center)
            double angular_scale = PWM_MAX_DEVIATION / MAX_INPUT_ANGULAR_VEL;
            int steering_pwm = static_cast<int>(PWM_CENTER + (angular_w * angular_scale));

            // Safety Limits 
            throttle_pwm = std::clamp(throttle_pwm, 1000, 2000);
            steering_pwm = std::clamp(steering_pwm, 1000, 2000);

            // Format into a string buffer
            std::ostringstream oss;
            oss << throttle_pwm << "," << steering_pwm << "\n";
            std::string serial_packet = oss.str();

            // Write bytes directly to the Linux file descriptor
            write(serial_fd_, serial_packet.c_str(), serial_packet.length());

            // Log the output
            RCLCPP_INFO(this->get_logger(), "Packet Out -> %s", serial_packet.c_str());


        }

        // Private member variables
        int serial_fd_;
        rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscription_;
};

int main(int argc, char * argv[])
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<McuBridgeNode>());
    rclcpp::shutdown();
    return 0;
}

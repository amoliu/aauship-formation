#include "ros/ros.h"
#include "aauship/ADIS16405.h"
#include <tf/transform_broadcaster.h>
#include <visualization_msgs/Marker.h>
#include <aauship/test.h>

// This node shall read imu measurements and use an AHRS filter to
// calculate attitude and publish such that it can render something
// in rviz.

// Construct filter
AHRS u(8.8, 0.5, 10);

void adisCallback(const aauship::ADIS16405::ConstPtr& msg)
{
  /* AHRS update */
  u.MahonyAHRSupdate(msg->xgyro, msg->ygyro, msg->zgyro, msg->xaccl, msg->yaccl, msg->zaccl, msg->xmagn, msg->ymagn, msg->zmagn);
  
  /* AHRS debug output */
  ROS_INFO("Quaternions: [%.3f, %.3f, %.3f, %0.3f]", u.getQuaternions(1), u.getQuaternions(2), u.getQuaternions(3), u.getQuaternions(0));
  u.calculateEulerAngles();
//  ROS_INFO("Euler angles: [%.3f, %.3f, %.3f]", u.getEulerAngles(0), u.getEulerAngles(1), u.getEulerAngles(2));
//  ROS_INFO("getTuning: [%.3f, %.3f]", u.getTuning(0), u.getTuning(1));
//  ROS_INFO("sampleFreq: [%.3f]", u.getSampleFreq());
  
  /* Publish rviz information */
  static tf::TransformBroadcaster tfbc;
  tf::Transform transform;
  transform.setOrigin( tf::Vector3(0,0,0) );
//  tf::Quaternion q(u.getQuaternions(0),u.getQuaternions(1),u.getQuaternions(2),u.getQuaternions(3));
  tf::Quaternion q;
  q.setRPY(u.getEulerAngles(0), u.getEulerAngles(1), u.getEulerAngles(2));
  transform.setRotation(q);
  tfbc.sendTransform( tf::StampedTransform(transform, ros::Time::now(), "map", "boat"));
}

// Used to configure the filter
void ahrsCallback(const aauship::ADIS16405::ConstPtr& msg)
{
//  setTuning(float kpA, float kiA, float kpM, float kiM);
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "ahrs_mahony");
  ros::NodeHandle adis;
  ros::Subscriber adissub = adis.subscribe("adis16405", 2, adisCallback);
  ros::NodeHandle ahrs;
  ros::Subscriber ahrssub = ahrs.subscribe("ahrs", 2, ahrsCallback);
  ros::spin();

  return 0;
}

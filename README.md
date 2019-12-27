```
docker run \
    --network="host" \
    --env="ROS_IP=$ROS_IP" \
    --env="ROS_MASTER_URI=$ROS_MASTER_URI" \
    -v "/tmp:/home/jovyan" \
    -p "8888:8888" \
    frankjoshua/ros-jupyter
```

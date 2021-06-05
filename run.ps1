# --net host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY 
docker run -it --rm -p 5900:5900 -v ./mt4:/MetaTrader docker-metatrader
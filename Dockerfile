FROM kasmweb/core-ubuntu-focal:1.13.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Teddit ###########
RUN apt update && apt-add-repository universe && apt update && apt install uwsgi nginx firefox npm nodejs sudo redis-server ffmpeg git -y
COPY teddit teddit
WORKDIR teddit
RUN npm install --no-optional
RUN cp config.js.template config.js
RUN npm install pm2 -g

######## Searx #############
WORKDIR $HOME
COPY searx searx
WORKDIR searx
RUN sudo -H ./utils/searx.sh install all


######## Searx Server ###########
#COPY searx-nginx /etc/nginx/sites-enabled/searx
#RUN mkdir -p /run/uwsgi/app/searx/ 
#RUN sudo -H chown -R searx:searx /run/uwsgi/app/searx/


######### Startup Services ####################
WORKDIR $HOME
RUN echo "cd /home/kasm-user/teddit/ && pm2 start app.js --name teddit && /usr/bin/uwsgi --ini /etc/uwsgi/apps-enabled/searx.ini --daemonize /tmp/searx.log" > $STARTUPDIR/custom_startup.sh \
&& chmod +x $STARTUPDIR/custom_startup.sh

######### End Customizations ###########
RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME


USER 1000




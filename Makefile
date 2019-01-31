build: comment post ui cloudprober prometheus blackbox-exporter alertmanager
push: push_comment push_post push_ui push_cloudprober push_blackbox-exporter push_alertmanager

comment:
	cd src/comment && bash docker_build.sh

post:
	cd src/post && bash docker_build.sh

ui:
	cd src/ui && bash docker_build.sh

cloudprober:
	cd monitoring/cloudprober && docker build -t ${USER_NAME}/cloudprober .

prometheus:
	cd monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .

blackbox-exporter:
	cd monitoring/prometheus && docker build -t ${USER_NAME}/blackbox_exporter .

alertmanager:
	cd monitoring/alertmanager &&  docker build -t ${USER_NAME}/alertmanager .

push_comment:
	docker push ${USER_NAME}/comment

push_post:
	docker push ${USER_NAME}/post

push_ui:
	docker push ${USER_NAME}/ui

push_cloudprober:
	docker push ${USER_NAME}/cloudprober

push_prometheus:
	docker push ${USER_NAME}/prometheus

push_blackbox-exporter:
	docker push  ${USER_NAME}/blackbox_exporter

push_alertmanager:
	docker push ${USER_NAME}/alertmanager

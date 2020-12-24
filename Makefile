dev:
	cd app && yarn dev

build:
	cd app && yarn generate

data:
	rm -f patients.csv
	wget https://www.harp.lg.jp/opendata/dataset/1369/resource/2828/patients.csv
	nkf -wd --overwrite patients.csv
	mv patients.csv app/static/file/patients.csv

json:
	yq r firebase.yaml --tojson | jq . > firebase.json

serve:
	# @make build
	@make json
	firebase serve

deploy:
	# @make build
	@make json
	firebase deploy

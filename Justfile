docker_tag := "latest"
docker_image := "ivhs_broker" + ":" + docker_tag

# Starts the dev environment by default
default: dev

docker-build:
	docker build -t {{docker_image}} .

docker-run: 
	docker run \
		-e SECRET_KEY_BASE=$SECRET_KEY_BASE \
		-e LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
	  -e MQTT_HOST=$MQTT_HOST \
		-p 4001:4000 \
		{{docker_image}}

boot-db:
	docker compose up -d

# Starts a development server
dev: deps boot-db create-db iex-server

# Install Node assets
setup-assets:
	npm install --prefix assets

# Creates database
create-db:
	mix ecto.create

# Resets database
reset-db:
	mix ecto.reset

# Starts an iex session
iex:
	iex -S mix

# Starts an iex session with Phoenix server
iex-server:
	iex -S mix phx.server

# Clean up dependencies
clean:
	rm -rf _build deps

# Clean dependencies and reinstall them
refresh: clean deps

# Install dependencies
deps:
	mix deps.get

install-actions-deps:
	npm install --prefix .github/actions/tag_repo

build-actions: install-actions-deps
  cd .github/actions/tag_repo && npm run build

webhook reader_name uid state:
	curl -X POST --json '{"reader_name":"{{reader_name}}", "uid": "{{uid}}","state":"{{state}}"}' http://localhost:4000/webhooks/card_reads

generate-cover source destination:
	mkdir -p ./card_covers
	node scripts/generate_card.mjs "{{source}}" ./card_covers/"{{destination}}"

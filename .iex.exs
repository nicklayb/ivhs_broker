alias IvhsBroker.Schema.Device
alias IvhsBroker.Schema.Card
alias IvhsBroker.Schema.CardRead
alias IvhsBroker.Repo

import Ecto.Query

{:ok, client} = IvhsBroker.Mqtt.Client.connect()
{:ok, _} = IvhsBroker.Mqtt.Client.subscribe(client, "ivhs/card")

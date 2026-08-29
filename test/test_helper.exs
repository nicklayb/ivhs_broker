ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(IvhsBroker.Repo, :manual)

Mox.defmock(IvhsBroker.HttpMock, for: Box.Http.Adapter)

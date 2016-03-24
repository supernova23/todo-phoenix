require Logger
import Comeonin.Bcrypt, only: [checkpw: 2]
defmodule Chat2.SessionController do
	use Chat2.Web, :controller
	#plug :scrub_params, "session" when action in [:create]
	alias Chat2.Session

	def login(conn, _params) do
		render(conn, "login.html", changeset: User.changeset(%User{}))
	end

	def create(conn, params = %{"session" => session_params}) do
		#Logger.debug "#{username} - #{password}"
		Repo.get_by(User, username: session_params["username"])
			|> sign_in(session_params["password"], conn)
		#render(conn, "login.html", params: params)
	end

	defp sign_in(user, password, conn) when is_nil(user) do
		conn
			|> put_flash(:error, "Invalid username/password combination!")
			|> redirect(to: session_path(conn, :login))
	end

	defp sign_in(user, password, conn) do
		Logger.info "#{inspect user}"
		if checkpw(password, user.password_digest) do
			conn
				|> put_session(:current_user, %{id: user.id, username: user.username})
				|> redirect(to: page_path(conn, :index))
		else
			conn
				|> put_session(:current_user, nil)
				|> put_flash(:error, "Invalid username/password combination!")
    		|> redirect(to: session_path(conn, :login))
		end
	end
end

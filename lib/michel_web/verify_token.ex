defmodule MichelWeb.VerifyToken do
  require Logger

  def init(options), do: options

  def verify_token(token) do
    keys = Application.get_env(:michel, Michel.SecureTokens)
    Logger.debug("config : #{inspect(keys)}")

    {:ok, claims} = token |> Joken.peek_claims()
    token_issuer = claims["iss"]

    Logger.debug("issuers : #{inspect(token_issuer)}")

    iss_key = String.to_atom(token_issuer)

    if Keyword.has_key?(keys, iss_key) do
      pem_data = keys[iss_key]

      Logger.debug("pem data : #{inspect(pem_data)}")

      token_config = Joken.Config.default_claims(iss: claims["iss"])

      Joken.verify_and_validate(token_config, token, %Joken.Signer{
        alg: "RS256",
        jwk: JOSE.JWK.from_pem(pem_data[:key]),
        jws: JOSE.JWS.generate_key(%{"alg" => "RS256"})
      })
    else
      {:error, "unknown issuer"}
    end
  end
end

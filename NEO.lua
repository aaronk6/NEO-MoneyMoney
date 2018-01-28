-- Inofficial NEO (Antshares) Extension for MoneyMoney
-- Fetches NEO quantity for address via otcgo API
-- Fetches NEO price in EUR via coinmarketcap API
-- Returns cryptoassets as securities
--
-- Username: NEO (Antshares) Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2018 Jacubeit

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.2,
  description = "Include your NEO coins as cryptoportfolio in MoneyMoney by providing a NEO address (usernme, comma seperated) and a random Password",
  services= { "NEO" }
}

local neoAddress
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "NEO"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  neoAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "NEO",
    accountNumber = "Crypto Asset NEO",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestNeoPrice()
  GasPrices = requestGasPrice()

  for address in string.gmatch(neoAddress, '([^,]+)') do
    neoAndGasQuantity = requestNeoAndGasQuantityForNeoAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = neoAndGasQuantity:dictionary()["balance"][2]["amount"],
      price = prices["price_eur"],
    }

    s[#s+1] = {
      name = "GAS @ " .. address,
      currency = nil,
      market = "cryptocompare",
      quantity = neoAndGasQuantity:dictionary()["balance"][1]["amount"],
      price = GasPrices["price_eur"],
    }

    s[#s+1] = {
      name = "GAS Unclaimed @ " .. address,
      currency = nil,
      market = "cryptocompare",
      quantity = neoAndGasQuantity:dictionary()["unclaimed"],
      price = GasPrices["price_eur"],
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestNeoPrice()
  content = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()[1]
end

function requestGasPrice()
  content = connection:request("GET", cryptocompareGasRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()[1]
end


function requestNeoAndGasQuantityForNeoAddress(neoAddress)
  content = connection:request("GET", neoRequestUrl(neoAddress), {})
  json = JSON(content)
  
  return json
end


-- Helper Functions
function cryptocompareRequestUrl()
  return "https://api.coinmarketcap.com/v1/ticker/neo/?convert=EUR"
end 

function cryptocompareGasRequestUrl()
  return "https://api.coinmarketcap.com/v1/ticker/gas/?convert=EUR"
end 

function neoRequestUrl(neoAddress)
  neoChain = "https://neoscan.io//api/main_net/v1/get_address/"

  return neoChain .. neoAddress
end


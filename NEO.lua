-- Inofficial NEO (Antshares) Extension for MoneyMoney
-- Fetches NEO quantity for address via otcgo API
-- Fetches NEO price in EUR via coinmarketcap API
-- Returns cryptoassets as securities
--
-- Username: NEO (Antshares) Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2020 Jacubeit, aaronk6

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
  version = 1.00,
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

  for address in string.gmatch(neoAddress, '([^,]+)') do
    neoQuantity = requestNeoQuantityForNeoAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = neoQuantity,
      price = prices["price_eur"],
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

function requestNeoQuantityForNeoAddress(neoAddress)
  content = connection:request("GET", neoRequestUrl(neoAddress), {})
  json = JSON(content)
  result = json:dictionary()["balances"][1]["valid"]
  
  return result
end


-- Helper Functions
function cryptocompareRequestUrl()
  -- TODO: Chance antshares to NEO when API changes
  return "https://api.coinmarketcap.com/v1/ticker/neo/?convert=EUR"
end 

function neoRequestUrl(neoAddress)
  neoChain = "https://otcgo.cn/api/v1/balances/"

  return neoChain .. neoAddress
end


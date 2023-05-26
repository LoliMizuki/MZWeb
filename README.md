MZWeb (documenting ongoing)
====

# Summary

Base protocol for web service operations

# Usage

- 定義 project 專用的 WebServiceProrocol: MZWebSerivceProtocol
- 該 WebServiceProrocol 同時需要定義 RawResultType 和 ErrorType

# MZWeb

- 基礎定義
- ✏️ 需提供定義 base url 的方式

## MZWeb.Publisher

- 定義 Publisher
- 目前看來只是提供了 common 的 publisher (success / fail / email 檢查) 而已 ... 呵呵
- ✏️ 所以應該是要在修改 ~ 

## MZWeb.HttpMethod 

- ...

## MZWeb.ResultRawInfo (原: ResultInfo)

- web 回傳的原始 result, 理論上會經過 service 轉換後成為可用的 Result

## MZWeb.Support

- 一些幫助 function
- 解讀 data
- log()

# MZWebError

- 定義 error type
- ✏️ 該該是用戶自行定義的說
- ✏️ 需要提供驗證 email 的實作

# MZWebSerivceProtocol

- service 需實作的 protocol
- 定義 service 的 input, output, 並產生 publisher
- request() 還需要加入 extra, 以加入其他 info (e.g. token ~)
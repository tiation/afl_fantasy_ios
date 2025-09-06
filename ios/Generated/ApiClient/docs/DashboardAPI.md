# DashboardAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDashboard**](DashboardAPI.md#getdashboard) | **GET** /v1/dashboard | Get dashboard data


# **getDashboard**
```swift
    open class func getDashboard(completion: @escaping (_ data: DashboardResponse?, _ error: Error?) -> Void)
```

Get dashboard data

Returns comprehensive dashboard information including team value,  current rank, upcoming matchups, and top performing players. 

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


// Get dashboard data
DashboardAPI.getDashboard() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DashboardResponse**](DashboardResponse.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


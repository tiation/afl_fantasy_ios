# PlayerDetail

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **Int** | Unique player identifier | 
**name** | **String** | Player full name | 
**team** | **String** | AFL team name | 
**position** | **String** | Playing position | 
**price** | **Int** | Current player price in cents | 
**avg** | **Float** | Season average fantasy score | 
**lastScore** | **Int** | Most recent fantasy score | [optional] 
**ownership** | **Float** | Ownership percentage | [optional] 
**breakeven** | **Int** | Breakeven score needed for price rise | [optional] 
**form** | **String** | Current form rating | [optional] 
**injury** | **String** | Injury status | [optional] 
**stats** | [**PlayerStats**](PlayerStats.md) |  | [optional] 
**fixtures** | [Fixture] |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



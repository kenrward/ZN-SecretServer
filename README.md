# ZN-SecretServer
Configuration to use Delinea Secret Server for Zero Networks Segmentation Server password rotation


# Requirements

1. Duplicate Generic API Key 
`Settings > Secret templates`
2. Name it **ZN API Key**
3. Add field `urlBase` Type TEXT
4. Create a new secret type **ZN API Key**
5. Get code and urlbase from ZN Portal
6. Duplicate Active Directory Account
`Settings > Secret templates`
7. Name it **ZN Active Directory Account**
8. Create new password changers based off Active Directory Account
9. Call it Zero Networks SVC Changer
10. Set script args and bypass verify
11. Enable remote password changing for **ZN Active Directory Account**
12. Change Password type to **Zero Networks SVC Changer**


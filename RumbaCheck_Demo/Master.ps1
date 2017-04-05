# Url on which request has to be send 
$GetLicenseProducturl="http://int.osb.rumba.pearsonmg.com/LicensedProduct/services"
$Authorizationurl="http://authorization.rumba.int.pearsoncmg.com/Authorization/services/V2"
$OrganizationLifeCycleurl="http://organization.rumba.int.pearsoncmg.com/OrganizationLifeCycle/services/2009/07/01"
$UserLifeCycleurl="http://user.rumba.int.pearsoncmg.com/UserLifeCycle/services/read/V3"

# Soap xml script
$soap_GetLicenseProduct = [xml]@'
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="http://licensedproduct.rws.pearson.com/doc/2009/06/01/">
   <soap:Header/>
   <soap:Body>
      <ns:GetLicensedProductRequestElement>
         <ns:GetLicensedProduct>
            <ns:OrganizationId>8a9480be20d9c9430120da2977b80bb8</ns:OrganizationId>
            <ns:QualifyingLicensePool>RootAndParents</ns:QualifyingLicensePool>
         </ns:GetLicensedProduct>
      </ns:GetLicensedProductRequestElement>
   </soap:Body>
</soap:Envelope>
'@

$soap_Authorization =[xml]@'
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:v2="http://authorization.rws.pearson.com/doc/V2/">
<soap:Header/>
<soap:Body>
<v2:AuthorizationRequest>
<v2:AuthorizationRequestType>
<v2:UserId>ffffffff50b8cb0be4b03300e1a0b310</v2:UserId>
<v2:AuthorizationContextId>1</v2:AuthorizationContextId>
</v2:AuthorizationRequestType>
</v2:AuthorizationRequest>
</soap:Body>
</soap:Envelope>
'@


$soap_OrganizationLifeCycle =[xml]@'
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="http://organization.rws.pearson.com/doc/2009/07/01/">
<soap:Header/>
<soap:Body>
<ns:GetOrganizationByIdRequest>
<ns:OrganizationIdRequestType>
<ns:OrganizationId>8a97b1a73b48fc84013b51d52388592f</ns:OrganizationId>
</ns:OrganizationIdRequestType>
</ns:GetOrganizationByIdRequest>
</soap:Body>
</soap:Envelope>
'@


$soap_UserLifeCycle =[xml]@'
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:v3="http://user.rws.pearson.com/doc/V3/">
<soap:Header/>
<soap:Body>
<v3:GetUserRequest>
<v3:UserId>ffffffff50b8cb0be4b03300e1a0b310</v3:UserId>
</v3:GetUserRequest>
</soap:Body>
</soap:Envelope>
'@
$ErrorFile="C:\Error.text"
$GetLicenseProduct="D:\Pegasus\PShell\RumbaCheck_Demo\GetLicenseProduct.response" 
$Authorization="D:\Pegasus\PShell\RumbaCheck_Demo\Authorization.response"
$OrganizationLifeCycle="D:\Pegasus\PShell\RumbaCheck_Demo\OrganizationLifeCycle.response"
$UserLifeCycle="D:\Pegasus\PShell\RumbaCheck_Demo\UserLifeCycle.response"
$responsefilelocation="D:\Pegasus\PShell\RumbaCheck_Demo\*.response"
$FileExists =(Test-Path $responsefilelocation)
$ContentType="application/soap+xml"
$EmailTo = “shilpi.ahuja@imfinity.com”
$EmailFrom = “ashutosh.kumar@imfinity.com”
$SMTPServer = “mailhost.pearsoncmg.com”


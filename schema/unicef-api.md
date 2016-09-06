## <a name="resource-report"></a>Report

The Report schema

### Report Create

Create a new report.

```
POST /v1/reports
```

#### Required Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **address** | *string* | Child's address | `"Rua Visconde de Pirajá, 211"` |
| **district** | *string* | Child's neighborhood | `"Ipanema"` |
| **number** | *number* | Child's address number | `"211"` |
| **user_id** | *uuid* | ID of the user which is reporting | `"1320"` |
| **reportee_name** | *string* | Child's name | `"Maria Joaquina"` |


#### Optional Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **probable_cause** | *number* | ID of the probable cause | `"2"` |
| **reference** | *string* | Reference to the child's address | `"Bem na esquina"` |
| **reportee_birthdate** | *string* | Child's birthday date | `"27/01/2000"` |
| **reportee_mother_name** | *string* | Child's mother name | `"Joana Joaquina"` |


#### Curl Example

```bash
$ curl -n -X POST http://github.com/ntxcode/zup-unicef-api/v1/reports \
  -H "Content-Type: application/json" \
 \
  -d '{
  "address": "Rua Visconde de Pirajá, 211",
  "district": "Ipanema",
  "number": "211",
  "user_id": "1320",
  "probable_cause": "2",
  "reference": "Bem na esquina",
  "reportee_birthdate": "27/01/2000",
  "reportee_mother_name": "Joana Joaquina",
  "reportee_name": "Maria Joaquina"
}'
```


#### Response Example

```
HTTP/1.1 201 Created
```

```json
{
}
```



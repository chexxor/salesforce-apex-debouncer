# salesforce-apex-debouncer

Will use too much of the "Scheduled Jobs" limit (100 per org), so dumping this untested code here
The code is still really cool, though, so I'll dump it here for other people to reference.

## Example

``` java
// ExampleTriggerOnEvent.cls

String notificationJobNamePrefix = 'Checklist_Notification_Job:' + UserInfo.getUserId() + ':' + Datetime.now();
String uniqueJobName = notificationJobNamePrefix + ':' + UserInfo.getUserId() + ':' + Datetime.now();

// A function which decides whether the event has settled.
TC_FunctionCall eventCheck = new TC_FunctionCall(
        'TC_ContentDocumentNotificationJob',
        'isAddingDocs',
        new Map<String, Object> { 'userId' => UserInfo.getUserId() });

// The program to execute when the action has settled.
TC_FunctionCall continuation = new TC_FunctionCall(
        'TC_ContentDocumentNotificationJob',
        'notifyOppOwner',
        new Map<String, Object> { 'userId' => UserInfo.getUserId(), 'actionStartDateTime' => Datetime.now() });

TC_EventDebounceLib.debounce(uniqueJobName, 5, 15, eventCheck, continuation);
```

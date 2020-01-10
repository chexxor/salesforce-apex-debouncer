trigger TC_ContentDocument on ContentDocument (after insert) {

    // When an external user is uploading files, wait until their actions have settled before generating the notification.
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

/* This part is where I discovered the problem with this design.
    // Does this job already exist?
    // CronJobDetail.JobType: '7' = Scheduled Apex
    List<CronTrigger> cronTriggers = [SELECT Id, TimesTriggered, NextFireTime, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
            FROM CronTrigger
            WHERE CronJobDetail.JobType = '7'];
    for (CronTrigger ct : cronTriggers) {
        if (ct.CronJobDetail.Name == null || !ct.CronJobDetail.Name.contains(notificationJobNamePrefix)) {
            continue;
        }
        List<String> cronJobNameParts = ct.CronJobDetail.Name.split(':');
        String notificationCreatorUserId = cronJobNameParts.get(1);
        if (notificationCreatorUserId == UserInfo.getUserId()) {}
    }
*/

    // !!! There is a limit to the number of CronTriggers of JobType '7' (scheduled jobs) an org can have.
    // With the current design, there will be one for each user uploading docs.

    // When the specified event completes, run the specified continuation
    EventDebounceLib.debounce(uniqueJobName, 5, 15, eventCheck, continuation);
}

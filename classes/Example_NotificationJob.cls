public with sharing class Example_NotificationJob implements Callable {

    public static Object call(String message, Map<String, Object> args) {
        switch on message {
            // When this returns `false`, the user is done adding docs, which means a notification should be sent.
            when 'isAddingDocs' {
                Id userId = Id.valueOf(String.valueOf(args.get('userId')));
                // Q: How can we know whether a user is done adding docs?
                // A: We can see if they created any docs in the last five minutes.
                Datetime fiveMinAgo = Datetime.now().addMinutes(-5);
                List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE CreatedById = :userId AND CreatedDate >= :fiveMinAgo];
                if (cds == null && cds.size() == 0) {
                    return false;
                } else {
                    return true;
                }
            }
            // A program which notifies an Opportunity owner of the changes made to a checklist.
            when 'notifyOppOwner' {
                Id userId = Id.valueOf(String.valueOf(args.get('userId')));
                Datetime actionStartDatetime = (Datetime)args.get('actionStartDateTime');
                Datetime fiveMinAgo = Datetime.now().addMinutes(-5);
                List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE CreatedById = :userId AND CreatedDate >= :actionStartDatetime];
                if (cds == null && cds.size() == 0) {
                    // No data to put in notification.
                    return false;
                }
                // Build email and send it.
                String emailTemplateName = 'My Email Name';
                EmailTemplate templ = (EmailTemplate) [SELECT Id FROM EmailTemplate WHERE Name = :emailTemplateName LIMIT 1];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templ.Id);
                email.setTargetObjectId(userId);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.Email> { email });
                if (results[0].success) {
                    System.debug('Successfully sent notification.');
                    return true;
                } else {
                    System.debug(LoggingLevel.ERROR, 'Failed to send notification.');
                    return false;
                }
            }
            when else {
                System.debug('Invalid message: ' + message);
                return false;
            }
        }
    }
}

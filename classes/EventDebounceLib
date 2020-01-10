global with sharing class EventDebounceLib implements Schedulable {

    // When the specified action completes, run the specified continuation.
    // - `eventCheck` is a `Callable` that should produce a Boolean value which indicates whether an event has settled.
    // - `continuation` is a `Callable` that continues a desired program.
    // - `pollPeriod` is the time between executing the `eventCheck` function.
    // - `maxDebounceTime` is the max amount of time an event is allowed to debounce before calling `continuation`.
    public static void debounce(String jobName, Integer pollPeriod, Integer maxDebounceTime,
            FunctionCall eventCheck, FunctionCall continuation) {
        EventDebounceLib.waitThenRun(jobName, pollPeriod, maxDebounceTime, eventCheck, continuation);
    }

    String jobName;
    Integer pollPeriod; // How often to check the event is complete, in minutes.
    Integer maxDebounceTime; // The max time of an event, in minutes.
    FunctionCall eventCheck;
    FunctionCall continuation;
    global EventDebounceLib(String jobName, Integer pollPeriod, Integer maxDebounceTime,
            FunctionCall eventCheck, FunctionCall continuation) {
        this.jobName = jobName;
        this.maxDebounceTime = maxDebounceTime;
        this.pollPeriod = pollPeriod;
        this.eventCheck = eventCheck;
        this.continuation = continuation;
    }
    global void execute(SchedulableContext context) {
        // CronJobDetail.JobType: '7' = Scheduled Apex
//            CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
//                    FROM CronTrigger
//                    WHERE Id = :jobId];
        // In this context, a scheduled job is a one-time program execution,
        //   so we should cancel this scheduled job now that it's been started.
        System.abortJob(context.getTriggerId());
        // Decrease the "maxDebounceTime", as it serves as a kind of "fuel" for the debounce process.
        Integer maxDebounceTimeNow = Math.max(this.maxDebounceTime - pollPeriod, 0);
        EventDebounceLib.waitThenRun(this.jobName, this.pollPeriod, maxDebounceTimeNow, this.eventCheck, this.continuation);
    }

    private static void waitThenRun(String jobName, Integer pollPeriod, Integer maxDebounceTime,
            FunctionCall eventCheck, FunctionCall continuation) {
        Boolean isSettled = (Boolean) FunctionCall.call(eventCheck);
        if (isSettled) {
            Object result = FunctionCall.call(continuation);
            System.debug('Completed debounce.');
            System.debug('Continuation program result: ' + result);
        } else {
            Datetime nextCheck = Datetime.now().addMinutes(pollPeriod);
            // cron expression format: second, minutes, hours, day_of_month, month, day_of_week
            String nextCheckTimeExpression = String.format('{0} {1} {2} {3} {4} {5}', new List<Object> {
                    '0', nextCheck.minute(), nextCheck.hour(),
                    nextCheck.date().day(), nextCheck.date().month(), '?'
            });
            String jobId = System.schedule(jobName, nextCheckTimeExpression, new EventDebounceLib(
                    jobName, pollPeriod, maxDebounceTime, eventCheck, continuation));
            System.debug('Next debounce check jobId: ' + jobId);
        }
    }

}

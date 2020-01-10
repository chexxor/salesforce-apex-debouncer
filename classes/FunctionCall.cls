global with sharing class FunctionCall {
    public String functionClassName;
    public String functionActionName;
    public Map<String, Object> functionArgs;
    global FunctionCall() { }
    global FunctionCall(String functionClassName, String functionActionName, Map<String, Object> functionArgs) {
        this.functionClassName = functionClassName;
        this.functionActionName = functionActionName;
        this.functionArgs = functionArgs;
    }

    global static Object call(FunctionCall function) {
        Callable functionClass = (Callable) Type.forName(null, function.functionClassName).newInstance();
        return functionClass.call(function.functionActionName, function.functionArgs);
    }
}

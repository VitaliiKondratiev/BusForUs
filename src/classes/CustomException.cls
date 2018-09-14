public with sharing class CustomException extends Exception {
	public String name;
    public String message;
    public Integer code;

    public CustomException(String name, String message, Integer code) {
        this.name    = name;
        this.message = message;
        this.code    = code;
    }
}
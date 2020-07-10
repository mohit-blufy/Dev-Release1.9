public Interface iVirtualClass {
	AuthResponse getAccessToken(String code,String clientId,String secretKey,String redirectURI,String grantType);
    AuthResponse refreshAccessToken(String accessToken,String refreshToken,String clientId,String secretKey);
    String createSingleMeetingBody(String topic,  String startDateTime, Integer duration,  String agenda);
    String createRecurringMeetingBody(String topic, String startDateTime, Integer duration,  String agenda, String recurrenceType,  String weeklyDays, String endTimes);
    VirtualClassParser createMeeting(String body,String accessToken);
    Boolean deleteMeeting(String meetingId, String occurrenceId,String accessToken);
}
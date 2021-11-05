WITH Complete (DeleteRequestId, CompleteDateTime) AS
(
	SELECT
		PR.DeleteRequestId,
		MAX(PR.StatusTimestamp) AS CompleteDateTime
	FROM dbo.ParticipantResponse PR
		INNER JOIN dbo.Participant P ON PR.ParticipantId = P.ParticipantId
	WHERE P.Name = '<Name>' AND PR.Status = <Status>
	GROUP BY PR.DeleteRequestId
),

ParticipantStatus (DeleteRequestId, ParticipantId, ParticipantCompleteDateTime, ParticipantsOptedIn, ParticipantsCompleted) AS
(
	SELECT
		PROptIn.DeleteRequestId,
		PROptIn.ParticipantId,
		MAX(PRCompleted.StatusTimestamp) AS ParticipantCompleteDateTime,
		COUNT(*) OVER(PARTITION BY PROptIn.DeleteRequestID) AS ParticipantsOptedIn,
		SUM(CASE WHEN PRCompleted.Status = <Status> THEN 1 ELSE 0 END) OVER(PARTITION BY PROptIn.DeleteRequestID) ParticipantsCompleted
	FROM dbo.ParticipantResponse PROptIn
 		LEFT OUTER JOIN dbo.ParticipantResponse PRCompleted ON
			PRCompleted.ParticipantId = PROptIn.ParticipantId AND
			PRCompleted.DeleteRequestId = PROptIn.DeleteRequestId AND
			PRCompleted.Status = <Status>
	WHERE PROptIn.Status = <Status>
	GROUP BY PROptIn.DeleteRequestID, PROptIn.ParticipantId, PRCompleted.Status
)

SELECT
	NC.DeleteRequestId
	,PS.ParticipantId
	,MAX(ISNULL(P.CloseWindow, 0)) AS CloseWindow
	,DATEADD(DAY, MAX(ISNULL(P.CloseWindow, 0)), NC.CompleteDateTime) AS MaxCompletionDateTime
	,NC.CompleteDateTime
	,PS.ParticipantCompleteDateTime
	,PS.ParticipantsOptedIn
	,PS.ParticipantsCompleted
FROM
	Complete NC
		INNER JOIN ParticipantStatus PS ON PS.DeleteRequestId = NC.DeleteRequestId
		INNER JOIN dbo.Participant P ON P.ParticipantId = PS.ParticipantId
WHERE PS.ParticipantsCompleted = PS.ParticipantsOptedIn
GROUP BY
	NC.DeleteRequestId,
	PS.ParticipantId,
	NC.CompleteDateTime,
	PS.ParticipantCompleteDateTime,
	PS.ParticipantsOptedIn,
	PS.ParticipantsCompleted
HAVING DATEADD(DAY, MAX(ISNULL(P.CloseWindow, 0)), NC.CompleteDateTime) < CURRENT_TIMESTAMP
ORDER BY
	NC.DeleteRequestId,
	PS.ParticipantId;
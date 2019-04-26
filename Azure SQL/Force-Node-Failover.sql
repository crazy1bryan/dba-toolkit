-- Forces a failover to another replica in the Microsoft data center (causes ~10 second downtime/disruption).
-- It may also be recommended by Microsoft to capture a process dump. DON'T DO THIS IN PRODUCTION WITHOUT MICROSOFT GUIDANCE!
DBCC STACKDUMP(-1);
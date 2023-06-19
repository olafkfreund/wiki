# SIEM and SOAR

## Designing a strategy for SIEM and SOAR <a href="#_idparadest-60" id="_idparadest-60"></a>

Important aspect of the security operations strategy is the ability to create an architecture that utilizes tools for the SOC team to hunt and investigate activity and event log data from multiple sources. SIEM and SOAR solutions can facilitate this capability. Let’s define the two for clarity.

A **security information event management** (**SIEM**) solution is usually deployed within a security operations center that gathers logs and events from various appliances and software within an IT infrastructure. A SIEM solution then analyzes the logs and events for potential threats by searching for behavior that is not typical of best practices or may be seen as anomalous or atypical. The benefit of a SIEM is that without one, security operations personnel would need to review each of these log and event files manually. Since there are thousands of log and event files within companies, this option has the potential for mistakes as fatigue becomes an issue when analyzing and identifying log changes. SIEM identifies the logs and events that could be a threat; then, security personnel can investigate these potential threats. This decreases the time to recognize a threat or vulnerability, allowing the security operations team to be more efficient and effective in their investigations.

A **security orchestration automated response** (**SOAR**) solution is a complementary solution to a SIEM. By initiating a workflow, SOAR solutions can add automation to the response of potential events identified as threats in the log files. An example of this would be an activity log from a device accessed from a location that has been flagged as a threat. SOAR can initiate a workflow to take that device offline and send an alert to the security operations response team to investigate.
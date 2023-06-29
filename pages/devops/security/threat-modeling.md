# Threat Modeling

Threat modeling is an effective way to help secure your systems, applications, networks, and services. It's a systematic approach that identifies potential threats and recommendations to help reduce risk and meet security objectives earlier in the development lifecycle.

### Threat Modeling Phases <a href="#threat-modeling-phases" id="threat-modeling-phases"></a>

1. _Diagram_\
   Capture all requirements for your system and create a data-flow diagram
2. _Identify_\
   Apply a threat-modeling framework to the data-flow diagram and find potential security issues. Here we can use [STRIDE framework](https://learn.microsoft.com/en-us/training/modules/tm-use-a-framework-to-identify-threats-and-find-ways-to-reduce-or-eliminate-risk/1b-threat-modeling-framework) to identify the threats.
3. _Mitigate_\
   Decide how to approach each issue with the appropriate combination of security controls.
4. _Validate_\
   Verify requirements are met, issues are found, and security controls are implemented.

Example of these phases is covered in the [threat modelling example.](https://microsoft.github.io/code-with-engineering-playbook/security/threat-modelling-example/)\
More details about these phases can be found at [Threat Modeling Security Fundamentals.](https://learn.microsoft.com/en-us/training/paths/tm-threat-modeling-fundamentals/)

### Threat Modeling Example <a href="#threat-modeling-example" id="threat-modeling-example"></a>

[Here is an example](overview.md) of a threat modeling document which talks about the architecture and distinct phases involved in the threat modeling. This document can be used as reference template for creating threat modeling documents.

# OWASP Zap Scan

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*mo_IA7Z5xJdY7IIpoZVz0A.png" alt="Owasp Zap is the world’s most widely used open source web app scanner tool" height="279" width="700"><figcaption><p><a href="https://www.zaproxy.org/">www.zaproxy.org</a></p></figcaption></figure>

In the past, security was stuck in the final stage of development, meaning that it was shifted quite right. That was not as problematic when development cycles lasted so long. However, nowadays, DevOps is getting faster and faster but security is lagging behind. To overcome this issue, security should be shifted as left as possible. Thus, you should put a security stage during your build so as to achieve a far more secure environment. Here come some open source tools for this approach one of which is Owasp Zap.

```yaml
resources:
  repositories:
    - repository: <repo_name>
      type: git
      name: <project_name>/<repo_name>
      ref: refs/heads/master

trigger: none

stages:
- stage: 'buildstage'
  jobs:
  - job: 'buildjob'
    pool: 
      vmImage: 'ubuntu-latest'
    steps:
    - checkout: self
    - checkout: <repo_name>

    - bash: docker run -d -p <container_port>:<target_port> <your_image>
      displayName: 'App Container'

    - bash: |
        chmod -R 777  ./
        docker run --rm -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-full-scan.py -t http://$(ip -f inet -o addr show docker0 | awk '{print $4}' | cut -d '/' -f 1):<container_port> -x 
xml_report.xml
        true
      displayName: 'Owasp Container Scan'

    - powershell: |
        $XslPath = "<repo_name>/xml_to_nunit.xslt" 
        $XmlInputPath = "xml_report.xml"
        $XmlOutputPath = "converted_report.xml"
        $XslTransform = New-Object System.Xml.Xsl.XslCompiledTransform
        $XslTransform.Load($XslPath)
        $XslTransform.Transform($XmlInputPath, $XmlOutputPath)
      displayName: 'PowerShell Script'
    - task: PublishTestResults@2
      displayName: 'Publish Test Results'
      inputs:
        testResultsFormat: 'NUnit'
        testResultsFiles: 'converted_report.xml'
```plaintext

_**Test and then you will see the test results**_

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*JNlsBGoUjDfRo3ftQ0W4YA.png" alt="" height="453" width="700"><figcaption></figcaption></figure>

**Note: **_**Ignore the warnings that were created during “Publish Test Results” task**_

## Security Testing with Owasp Zap Task

\


```yaml
trigger: none
    
stages:
- stage: 'buildstage'
  jobs:
  - job: 'buildjob'
    pool: 
      vmImage: 'ubuntu-latest'
    steps:
    - checkout: self

    - bash: docker run -d -p <container_port>:<target_port> <your_image>
      displayName: 'App Container'

    - task: owaspzap@1
      inputs:
        aggressivemode: true
        threshold: '50'
        port: '<target_port>'
      displayName: 'Owasp Scan'

    - bash: |
        sudo npm install -g handlebars-cmd
        sudo cat <<EOF > owaspzap/nunit-template.hbs
        {{#each site}}
        <test-run
            id="2"
            name="Owasp test"
            start-time="{{../[@generated]}}"  >
            <test-suite
                id="{{@index}}"
                type="Assembly"
                name="{{[@name]}}"
                result="Failed"
                failed="{{alerts.length}}">
                <attachments>
                    <attachment>
                        <filePath>owaspzap/report.html</filePath>
                    </attachment>
                </attachments>
            {{#each alerts}}<test-case
                id="{{@index}}"
                name="{{alert}}"
                result="Failed"
                fullname="{{alert}}"
                time="1">
                    <failure>
                            <message>
                             <![CDATA[{{{desc}}}]]>
                        </message>
                        <stack-trace>
                            <![CDATA[
        Solution:
        {{{solution}}}
        Reference:
        {{{reference}}}
        instances:{{#each instances}}
        * {{uri}}
            - {{method}}
            {{#if evidence}}- {{{evidence}}}{{/if}}
                             {{/each}}]]>
                         </stack-trace>
                    </failure>
            </test-case>
            {{/each}}
            </test-suite>
        </test-run>
        {{/each}}
        EOF
      displayName: 'Owasp Nunit Template'
    - bash: 'handlebars owaspzap/report.json < owaspzap/nunit-template.hbs > owaspzap/test-results.xml'
      displayName: 'Generate Nunit type file'


    - task: PublishTestResults@2
      displayName: 'Publish Test Results'
      inputs:
        testResultsFormat: 'NUnit'
        testResultsFiles: 'owaspzap/test-results.xml'
```plaintext

_**After executing the pipeline, you can see the test results**_

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*JNlsBGoUjDfRo3ftQ0W4YA.png" alt="" height="453" width="700"><figcaption></figcaption></figure>

**Note: Ignore the warnings that were created during “Publish Test Results” task**

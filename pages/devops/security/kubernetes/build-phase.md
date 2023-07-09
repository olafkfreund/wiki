# Build Phase

### Kubernetes Security Best Practices: Build Phase[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#kubernetes-security-best-practices-build-phase) <a href="#kubernetes-security-best-practices-build-phase" id="kubernetes-security-best-practices-build-phase"></a>

Securing containers and Kubernetes starts in the build phase with securing your container images. The two main things to do here are to build secure images and to scan those images for any known vulnerabilities.

A Container image is an immutable, lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings \[[https://www.docker.com/resources/what-container](https://www.docker.com/resources/what-container)]. The image shares the kernel of the operating system present in its host machine.

Container images must be built using approved and secure base image that is scanned and monitored at regular intervals to ensure only secure and authentic images can be used within the cluster. It is recommended to configure strong governance policies regarding how images are built and stored in trusted image registries.

#### Ensure That Only Authorized Images are used in Your Environment[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#ensure-that-only-authorized-images-are-used-in-your-environment) <a href="#ensure-that-only-authorized-images-are-used-in-your-environment" id="ensure-that-only-authorized-images-are-used-in-your-environment"></a>

Without a process that ensures that only images adhering to the organization’s policy are allowed to run, the organization is open to risk of running vulnerable or even malicious containers. Downloading and running images from unknown sources is dangerous. It is equivalent to running software from an unknown vendor on a production server. Don’t do that.

#### Container registry and the use of an image scanner to identify known vulnerabilities[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#container-registry-and-the-use-of-an-image-scanner-to-identify-known-vulnerabilities) <a href="#container-registry-and-the-use-of-an-image-scanner-to-identify-known-vulnerabilities" id="container-registry-and-the-use-of-an-image-scanner-to-identify-known-vulnerabilities"></a>

Container registry is the central repository of container images. Based on the needs, we can utilize public repositories or have a private repository as the container registry. Use private registries to store your approved images - make sure you only push approved images to these registries. This alone reduces the number of potential images that enter your pipeline to a fraction of the hundreds of thousands of publicly available images.

Build a CI pipeline that integrates security assessment (like vulnerability scanning), making it part of the build process. The CI pipeline should ensure that only vetted code (approved for production) is used for building the images. Once an image is built, it should be scanned for security vulnerabilities, and only if no issues are found then the image would be pushed to a private registry, from which deployment to production is done. A failure in the security assessment should create a failure in the pipeline, preventing images with bad security quality from being pushed to the image registry.

Many source code repositories provide scanning capabilities (e.g. [Github](https://docs.github.com/en/code-security/supply-chain-security), [GitLab](https://docs.gitlab.com/ee/user/application\_security/container\_scanning/index.html)), and many CI tools offer integration with open source vulnerability scanners such as [Trivy](https://github.com/aquasecurity/trivy) or [Grype](https://github.com/anchore/grype).

There is work in progress being done in Kubernetes for image authorization plugins, which will allow preventing the shipping of unauthorized images. For more information, refer to the PR [https://github.com/kubernetes/kubernetes/pull/27129](https://github.com/kubernetes/kubernetes/pull/27129).

#### Use minimal base images and avoid adding unnecessary components[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-minimal-base-images-and-avoid-adding-unnecessary-components) <a href="#use-minimal-base-images-and-avoid-adding-unnecessary-components" id="use-minimal-base-images-and-avoid-adding-unnecessary-components"></a>

Avoid using images with OS package managers or shells because they could contain unknown vulnerabilities. If you must include OS packages, remove the package manager at a later step. Consider using minimal images such as distroless images, as an example.

Restricting what's in your runtime container to precisely what's necessary for your app is a best practice employed by Google and other tech giants that have used containers in production for many years. It improves the signal to noise of scanners (e.g. CVE) and reduces the burden of establishing provenance to just what you need.

**Distroless images**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#distroless-images)

Distroless images contains less packages compared to other images, and does not includes shell, which reduce the attack surface.

For more information on ditroless images, refer to [https://github.com/GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless).

**Scratch image**[**¶**](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#scratch-image)

An empty image, ideal for statically compiled languages like Go. Because the image is empty - the attack surface it truly minimal - only your code!

For more information, refer to [https://hub.docker.com/\_/scratch](https://hub.docker.com/\_/scratch)

#### Use the latest images/ensure images are up to date[¶](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes\_Security\_Cheat\_Sheet.html#use-the-latest-imagesensure-images-are-up-to-date) <a href="#use-the-latest-imagesensure-images-are-up-to-date" id="use-the-latest-imagesensure-images-are-up-to-date"></a>

Ensure your images (and any third-party tools you include) are up to date and utilizing the latest versions of their components.

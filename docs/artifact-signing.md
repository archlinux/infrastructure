# Artifact signing ([#280](https://gitlab.archlinux.org/archlinux/infrastructure/-/issues/280))

We have been discussing artifact signing from our CI for a long time, 
and there are a few different solutions.

@shibumi has helped sketching the solutions:

## GPG key in GitLab + transparency log (Rekor):

In this solution, the GPG key would be attached to the Gitlab Runner
as Gitlab Runner Secret. A pipeline run would build the artifact,
sign the artifact with the key and upload a transparency log of the 
recorded
artifact (https://docs.sigstore.dev/rekor/cli/).

Pros:
* Easy to implement
* Easier to detect key compromise (only with transparency log)

Cons:
* The users must remember to check the entity in the Rekor transparency 
log
* The GPG private key can get extracted from the pipeline and used 
elsewhere.
* The GPG private key is persistent and most users won't ever know if 
we revoke it.
* We have to write our own toolchain for creating and verifying rekor 
transparency logs.
* GPG does not enforce a transparency lookup

## GPG key in secure enclave + SSH key in GitLab + transparency log (Rekor)

In this solution, the GPG key would be embedded in a hardware module 
attached
to a server instance in the Hetzner DC. The signing server would only 
allow
incoming signing requests. Command line access via SSH is disabled.
The build pipeline would create a new signing request for the secure 
enclave
via SSH and upload the signature to the rekor transparency log as 
'rekord' artifact.

Pros:
* The GPG key is strictly attached to the server and cannot extracted 
on a different machine
* The transparency log would allow us to monitor for invalid signatures
* The setup is easy, but needs some custom tooling. Bluewind wrote a 
PoC for the secure enclave long ago.

Cons:
* Complex infrastructure (setting up the secure enclave)
* More infra to maintain
* The users must remember to check the entity in the Rekor transparency 
log
* The GPG key is persistent. This means, anyone with physical access to 
the Hardware Security Module (HSM) is able to steal the device with the 
private key and use it for creating valid signatures.
* Everyone with access to the gitlab or runner machine can issue a 
signing request and sign malicious software
* We have to write our own toolchain for creating and verifying rekor 
transparency logs.
* GPG does not enforce a transparency lookup

## Traditional signatures with cosign, transparency log and secure enclave

In this solution, we use cosign without the keyless functionality.
Instead of using workload identities for creating ephemeral key pairs,
we are creating one persistent key pair with cosign. This key pair
can be embedded into an HSM, too (yubikey/nitrokey?)

Pros:
* The cosign private key is strictly attached to the server and cannot 
extracted on a different machine
* The transparency log would allow us to monitor for invalid signatures
* The setup is easier than the setup with GPG (besides the part about 
setting up the secure enclave)
* Cosign enforces a transparency log lookup
* The cosign binary is much easier to bootstrap on systems like Windows 
than GnuPG

Cons:
* The private key is persistent and can be stolen.
* There is no way to revoke a private key (as far as I know)
* Everyone with access to the gitlab or runner machine can issue a 
signing request and sign malicious software

## Keyless signatures via cosign and workload identities

Pros:
* Better User Experience (single step verify via cosign verify-blob)
* Private keys are ephemeral, a later stolen private key is useless.
* The key identity is strictly connected to the pipeline run
* Creation of rekor transparency logs happens automatically
* Transparency lookups are enforced by cosign

Cons:
* Complex infrastructure (setting up the SPIRE service, SPIRE OIDC 
Discovery Provider, federate with Fulcio CA, workload attestation) 
(Note: This problem might can be solved with going into the Cloud).

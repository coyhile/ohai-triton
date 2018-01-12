# ohai-triton
ohai plugin to provide Triton Metadata

This plugin populates Joyent-sepcific metadata considered to be of use to its author.

# Unsupported functionality
## Triton CNS
This plugin has no way to populate CNS data into the ohai data as there is so far
as the author can tell no way to query the value of the metadata tag 
`triton.cns.services` from inside the instance.

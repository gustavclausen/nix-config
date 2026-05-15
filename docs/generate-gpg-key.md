# Generate GPG Key

```bash
gpg --full-generate-key
gpg --list-keys # Note key id
gpg --armor --export-key "<KEY_ID>" --output public.key > public.key
gpg --armor --export-secret-key "<KEY_ID>" --output private.key > private.key
gpg --list-secret-keys --keyid-format=long # Get signing key from `sec` field (e.g. `rsa30372/<signing key> 2024-02-24 [SC]`)
```

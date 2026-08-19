# homebrew-tunebox

Tap de Homebrew para [Tunebox](https://github.com/duvanherfi/tunebox), un
reproductor de música en Flutter que lee el catálogo de YouTube Music.

```
brew install --cask duvanherfi/tunebox/tunebox
```

Para actualizar, `brew upgrade --cask tunebox`.

## Por qué existe

La app de macOS está firmada, pero con una firma ad-hoc y no con un certificado
de pago de Apple. Eso basta para que funcione, y no basta para que macOS la abra
sin preguntar: cualquier copia que llega por un navegador trae el atributo de
cuarentena, y Gatekeeper la bloquea hasta que quien la instala la autoriza a
mano desde Ajustes del Sistema.

Homebrew quita ese atributo por su cuenta, así que instalada por aquí la app se
abre a la primera. Es la única forma de saltarse ese paso sin notarizar, y
notarizar pide el certificado de pago.

Si prefieres el `.dmg` suelto, está en las
[releases](https://github.com/duvanherfi/tunebox/releases) y las notas de cada
versión explican el paso de Ajustes.

## Cómo se actualiza

No a mano. `tool/bump_cask.sh`, en el repo principal, se ejecuta después de
publicar una release: descarga el `.dmg` que GitHub está sirviendo, saca su
`sha256` de ahí —no de un build local— y reescribe el cask entero. Un cask cuya
suma no coincide con lo que se descarga se niega a instalar, y detectar eso es
casi todo para lo que sirve la suma.

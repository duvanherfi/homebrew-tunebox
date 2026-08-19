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
[releases](https://github.com/duvanherfi/tunebox/releases), y las notas de cada
versión explican el paso de Ajustes.

## Cómo se mantiene al día

Solo. `.github/workflows/cask.yml` corre cada hora, mira la última release de
Tunebox, y si trae una imagen de disco distinta a la que apunta el cask lo
reescribe y lo commitea. `tool/render_cask.sh` es quien hace el trabajo, y se
puede correr a mano para ver qué saldría.

**El cask se genera entero, no se edita.** Hay una app en este tap y una sola
cosa que cambia de ella, así que una plantilla con huecos solo sería un segundo
sitio donde la versión puede estar mal. Editar `Casks/tunebox.rb` a mano no
sirve de nada: la siguiente ejecución lo sobrescribe.

### Por qué el tap tira en vez de que le empujen

Lo natural sería que el workflow de release de Tunebox, al publicar, empujara
aquí el cask nuevo. No se hizo así a propósito.

Para escribir en este repositorio desde allí haría falta un token con permiso
sobre él, guardado como secret en el repositorio de la app. Y ese repositorio
**no tiene ningún secret a nivel de repositorio**: la clave de firma de Android
vive en un *environment*, que es justo lo que impide que un workflow cualquiera
la lea. Un token que pudiera escribir aquí habría sido la primera excepción a
esa regla, y habría abierto un camino para publicar un cask que apunte a donde
no debe.

Tirando no hace falta nada: la API de releases es pública y no pide token, y el
`GITHUB_TOKEN` del propio workflow ya puede escribir en el repositorio al que
pertenece. El coste es que el cask puede tardar hasta una hora en enterarse de
una release; para eso está el disparo manual.

### Si el cask se queda atrás

GitHub apaga los workflows programados en un repositorio que lleva sesenta días
sin commits, que es exactamente el aspecto de un tap tranquilo. Si eso pasa, o
si no quieres esperar a la hora en punto:

```
gh workflow run cask.yml --repo duvanherfi/homebrew-tunebox
```

o el botón **Run workflow** en la pestaña Actions.

## Verificar antes de instalar

El cask lleva el `sha256` de la imagen de disco, sacado del archivo que GitHub
está sirviendo. Si no coincide con lo que descargas, `brew` se niega a instalar
— que es casi todo aquello para lo que sirve la suma.

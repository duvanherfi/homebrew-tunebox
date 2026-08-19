# homebrew-tunebox

Tap de Homebrew para [Tunebox](https://github.com/duvanherfi/tunebox), un
reproductor de música en Flutter que lee el catálogo de YouTube Music.

```
brew install --cask duvanherfi/tunebox/tunebox
```

Para actualizar, `brew upgrade --cask tunebox`.

## Esto no te ahorra el aviso de Gatekeeper

Conviene decirlo antes que nada, porque es fácil suponer lo contrario.

La app de macOS está firmada, pero con una firma **ad-hoc** y no con un
certificado de pago de Apple. Así que la primera vez macOS se niega a abrirla y
hay que autorizarla a mano desde **Ajustes del Sistema › Privacidad y
seguridad**.

**Homebrew no evita ese paso: lo aplica él mismo.** Marca en cuarentena lo que
instala, igual que un navegador. Y en las actualizaciones tampoco se libra: brew
solo libera la cuarentena de una versión nueva si la identidad de firma coincide
con la de la anterior, y la de una firma ad-hoc es el `cdhash` del binario, que
cambia en cada build:

```
ad-hoc        designated => cdhash H"08b5a248…"
Developer ID  designated => … certificate leaf[subject.OU] = ABCDE12345
```

Lo único que quita ese paso de verdad es **notarizar**, y eso pide el
certificado de pago. Si algún día se hace, este tap se beneficia solo: la
identidad pasa a ser estable y brew deja de re-marcar cada actualización.

## Entonces para qué sirve

Para lo que en macOS no hay de otra forma:

- **Actualizar.** La app no se actualiza sola en Mac — el actualizador integrado
  es de Android, porque su seguridad se apoya en comparar el certificado de
  firma, y en macOS no hay ninguno estable que comparar. Sin esto tocaría volver
  a la página de releases cada vez.
- **Instalar y desinstalar con un comando**, incluidos los restos que la app
  deja fuera de su carpeta (`brew uninstall --zap --cask tunebox`).
- **Comprobar la descarga.** El cask lleva el `sha256` de la imagen de disco; si
  no coincide, brew se niega a instalar.

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


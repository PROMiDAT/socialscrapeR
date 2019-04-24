
<!-- README.md is generated from README.Rmd. Please edit that file -->

# socialscrapeR

El propósito de este paquete es hacer sencillo el proceso de extracción
de datos de redes sociales como facebook y twitter.

## Instalación

Puedes instalar la versión de desarrollo con la instrucción:

``` r
install.packages("devtools")
devtools::install_github("PROMiDAT/socialscrapeR")
```

Este paquete utiliza selenium para simular la interacción de un usuario
con su cuenta de Facebook por lo que antes de comenzar se debe
inicializar el servidor de selenium.

## Iniciar el servidor de selenium

``` r
library(socialscrapeR)
session <- start_server(port = 4568L)
#>  ✔ Se inició con éxito el servidor de Selenium en el puerto 4568.
```

## Iniciar sesión en Facebook

``` r
login_facebook(x = session,
               username = "usuario",
               password = "clave")
#> Se está redirigiendo el navegador a la url: https://m.facebook.com ...
#> Se inición sesión en https://m.facebook.com con el usuario dev.aguero@gmail.com
```

Nota: Para evitar exponer tus credenciales en tu código se recomienda el
uso de paquete [keying](https://github.com/r-lib/keyring).

## Función `get_fb_posts`

Esta función nos retorna un data.frame con la información de las últimas
`n` publicaciones de una página, esta función recibe los siguiente
parámetros:

  - x = una conexión con selenium creada con la función start\_server en
    la que ya se inicio sesión en una cuenta de Facebook con la función
    `login_facebook`.
  - **pagename**: nombre de la página
  - **n** : cantidad mínima de publicaciones a descargar
  - **reactions** si el valor es TRUE se retorna en un data.frame
    información sobre las reacciones de los usuario a la publicación
  - **comments** : si el valor es TRUE se retorna en un data.frame el
    contenido de los comentarios de la publicación
  - **shares** : si el valor es TRUE se retorna en un data.frame
    información sobre los usuarios que compartieron la publicación

Veamos algunos ejemplos :

## Extraer las últimas 10 publicaciones de una pagina de Facebook

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 13
#> Variables: 6
#> $ page_id    <chr> "265769886798719", "265769886798719", "26576988679871…
#> $ post_id    <chr> "2806286759413673", "2806265406082475", "280621012275…
#> $ post_text  <chr> "assange fue detenido hoy, tras resguardarse por 7 añ…
#> $ n_comments <int> 0, 7, 63, 19, 5, 18, 17, 9, 36, 0, 5, 13, 169
#> $ n_shares   <int> 2, 4, 114, 32, 7, 15, 20, 1, 4, 2, 11, 5, 104
#> $ date_time  <dttm> 2019-04-11 16:16:29, 2019-04-11 16:05:29, 2019-04-11…
```

La función `get_fb_post` retorna los siguiente valores.

  - **page\_id** : identificador único de la página
  - **post\_id** : identificador único de la publicación
  - **post\_text** : contenido del texto principal de la publicación
  - **n\_comments** : cantidad de comentarios
  - **n\_shares** : cantidad de compartidos
  - **date\_time** : hora y fecha en la que se realizó la
publicación

## Extraer las últimas 10 publicaciones de una pagina de Facebook e información sobre las reacciones de la publicación.

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 13
#> Variables: 13
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2806286759413673", "2806265406082475", "28062…
#> $ post_text         <chr> "assange fue detenido hoy, tras resguardarse p…
#> $ n_comments        <int> 0, 7, 63, 19, 5, 18, 17, 9, 36, 0, 5, 13, 170
#> $ n_shares          <int> 2, 4, 114, 32, 7, 15, 20, 1, 4, 2, 11, 5, 104
#> $ like              <int> 0, 15, 74, 67, 23, 26, 14, 18, 24, 10, 22, 51,…
#> $ love              <int> 0, 0, 4, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1
#> $ wow               <int> 2, 0, 24, 23, 12, 15, 5, 2, 4, 0, 14, 2, 2
#> $ haha              <int> 0, 6, 137, 0, 1, 4, 1, 1, 0, 0, 0, 3, 90
#> $ sad               <int> 0, 2, 2, 44, 11, 0, 0, 0, 2, 0, 24, 0, 0
#> $ angry             <int> 0, 1, 8, 0, 0, 2, 21, 0, 30, 0, 0, 4, 81
#> $ reactions_by_user <list> [<tbl_df[2 x 3]>, <tbl_df[24 x 3]>, <tbl_df[2…
#> $ date_time         <dttm> 2019-04-11 16:16:29, 2019-04-11 16:05:29, 201…
tibble::glimpse(df$reactions_by_user[[1]])
#> Observations: 2
#> Variables: 3
#> $ full_name     <chr> "Fiorella Monge Villalobos", "'Eidy Guevara"
#> $ user_name     <chr> "/profile.php?id=100008106915815", "/eidy.guevara"
#> $ type_reaction <chr> NA, NA
```

La función `get_fb_post` retorna los siguiente valores.

  - **page\_id** : identificador único de la página
  - **post\_id** : identificador único de la publicación
  - **post\_text** : contenido del texto principal de la publicación
  - **n\_comments** : cantidad de comentarios
  - **n\_shares** : cantidad de compartidos
  - **like** : cantidad de “me gusta”
  - **love** : cantidad de “me encanta”
  - **wow** : cantidad de “me sorprende”
  - **haha** : cantidad de “me da risa”
  - **sad** : cantidad de “me entristece”
  - **angry** : cantidad de “me enoja”
  - **reactions\_by\_user** :
      - **full\_name** : nombre real del usuario
      - **username** : nombre de la cuenta del usuario
      - **type\_reaction** : reacción hecha por el usuario
  - **date\_time** : hora y fecha en la que se realizó la
publicación

## Extraer las últimas 10 publicaciones de una pagina de Facebook, información sobre las reacciones y comentarios de la publicación.

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T, commets = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 13
#> Variables: 14
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2806286759413673", "2806265406082475", "28062…
#> $ post_text         <chr> "assange fue detenido hoy, tras resguardarse p…
#> $ n_comments        <int> 1, 9, 64, 19, 5, 18, 17, 9, 37, 0, 5, 13, 172
#> $ n_shares          <int> 2, 5, 116, 32, 7, 15, 21, 1, 4, 2, 11, 5, 104
#> $ like              <int> 0, 16, 74, 67, 23, 26, 14, 18, 24, 10, 22, 51,…
#> $ love              <int> 0, 0, 4, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1
#> $ wow               <int> 2, 1, 24, 23, 12, 16, 5, 2, 4, 0, 14, 2, 2
#> $ haha              <int> 0, 6, 139, 0, 1, 4, 1, 1, 0, 0, 0, 3, 90
#> $ sad               <int> 0, 2, 2, 44, 11, 0, 0, 0, 2, 0, 24, 0, 0
#> $ angry             <int> 0, 1, 8, 0, 0, 2, 21, 0, 31, 0, 0, 4, 81
#> $ reactions_by_user <list> [<tbl_df[2 x 3]>, <tbl_df[26 x 3]>, <tbl_df[2…
#> $ comments          <list> [<tbl_df[2 x 3]>, <tbl_df[10 x 3]>, <tbl_df[6…
#> $ date_time         <dttm> 2019-04-11 16:16:29, 2019-04-11 16:05:29, 201…
```

La función `get_fb_post` retorna los siguiente valores.

  - **page\_id** : identificador único de la página
  - **post\_id** : identificador único de la publicación
  - **post\_text** : contenido del texto principal de la publicación
  - **n\_comments** : cantidad de comentarios
  - **n\_shares** : cantidad de compartidos
  - **like** : cantidad de “me gusta”
  - **love** : cantidad de “me encanta”
  - **wow** : cantidad de “me sorprende”
  - **haha** : cantidad de “me da risa”
  - **sad** : cantidad de “me entristece”
  - **angry** : cantidad de “me enoja”
  - **reactions\_by\_user** :
      - **full\_name** : nombre del usuario
      - **username** : nombre de la cuenta del usuario
      - **type\_reaction** : reacción hecha por el usuario
  - **comments** :
      - **full\_name** : nombre del usuario
      - **user\_name** : nombre de la cuenta del usuario
      - **text** : texto del comentario
  - **date\_time** : hora y fecha en la que se realizó la
publicación

## Extraer las últimas 10 publicaciones de una pagina de Facebook, información sobre las reacciones, comentarios de la publicación y los usuario que compartieron la aplicación.

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T, commets = T, shares = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 13
#> Variables: 15
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2806286759413673", "2806265406082475", "28062…
#> $ post_text         <chr> "assange fue detenido hoy, tras resguardarse p…
#> $ n_comments        <int> 2, 10, 68, 19, 5, 18, 17, 9, 37, 0, 5, 13, 173
#> $ n_shares          <int> 2, 5, 119, 32, 7, 16, 21, 1, 4, 2, 11, 5, 105
#> $ like              <int> 2, 17, 74, 69, 23, 26, 14, 18, 24, 10, 22, 52,…
#> $ love              <int> 0, 0, 4, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1
#> $ wow               <int> 2, 1, 25, 23, 12, 16, 5, 2, 4, 0, 14, 2, 2
#> $ haha              <int> 0, 6, 140, 0, 1, 4, 1, 1, 0, 0, 0, 3, 90
#> $ sad               <int> 0, 2, 3, 44, 11, 0, 0, 0, 2, 0, 24, 0, 0
#> $ angry             <int> 0, 1, 8, 0, 0, 2, 22, 0, 31, 0, 0, 4, 81
#> $ reactions_by_user <list> [<tbl_df[4 x 3]>, <tbl_df[27 x 3]>, <tbl_df[2…
#> $ comments          <list> [<tbl_df[3 x 3]>, <tbl_df[10 x 3]>, <tbl_df[6…
#> $ shares            <list> [NULL, <tbl_df[3 x 2]>, <tbl_df[30 x 2]>, <tb…
#> $ date_time         <dttm> 2019-04-11 16:16:29, 2019-04-11 16:05:29, 201…
```

La función `get_fb_post` retorna los siguiente valores.

  - **page\_id** : identificador único de la página
  - **post\_id** : identificador único de la publicación
  - **post\_text** : contenido del texto principal de la publicación
  - **n\_comments** : cantidad de comentarios
  - **n\_shares** : cantidad de compartidos
  - **like** : cantidad de “me gusta”
  - **love** : cantidad de “me encanta”
  - **wow** : cantidad de “me sorprende”
  - **haha** : cantidad de “me da risa”
  - **sad** : cantidad de “me entristece”
  - **angry** : cantidad de “me enoja”
  - **reactions\_by\_user** :
      - **full\_name** : nombre del usuario
      - **username** : nombre de la cuenta del usuario
      - **type\_reaction** : reacción hecha por el usuario
  - **comments** :
      - **full\_name** : nombre del usuario
      - **user\_name** : nombre de la cuenta del usuario
      - **text** : texto del comentario
  - **shares** :
      - **ful\_name** : nombre del usuario
      - **user\_name** : nombre de la cuenta de usuario
  - **date\_time** : hora y fecha en la que se realizó la publicación

### Cerrar el servidor

``` r
stop_server(session)
#>  ✔ Se cerró con éxito el servidor de Selenium.
#> NULL
```

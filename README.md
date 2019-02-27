
<!-- README.md is generated from README.Rmd. Please edit that file -->
socialscrapeR
=============

El propósito de este paquete es hacer sencillo el proceso de extracción de datos de redes sociales como facebook y twitter.

Instalación
-----------

Puedes instalar la versión de desarrollo con la instrucción:

``` r
install.packages("devtools")
devtools::install_github("PROMiDAT/socialscrapeR")
```

Este paquete utiliza selenium para simular la interacción de un usuario con su cuenta de Facebook por lo que antes de comenzar se debe inicializar el servidor de selenium.

Iniciar el servidor de selenium
-------------------------------

``` r
library(socialscrapeR)
session <- start_server()
#>  ✔ Se inició con éxito el servidor de Selenium en el puerto 4567.
```

Iniciar sesión en Facebook
--------------------------

``` r
login_facebook(x = session,
               username = keyring::key_get("facebook_email"),
               password = keyring::key_get("facebook_pass"))
#> Se está redirigiendo el navegador a la url: https://m.facebook.com ...
#> Se inición sesión en https://m.facebook.com con el usuario dev.aguero@gmail.com
```

Nota: Para evitar exponer tus credenciales en tu código se recomienda el uso de paquete [keying](https://github.com/r-lib/keyring).

Función `get_fb_posts`
----------------------

Esta función nos retorna un data.frame con la información de las últimas `n` publicaciones de una página, esta función recibe los siguiente parámetros:

-   x = una conexión con selenium creada con la función start\_server en la que ya se inicio sesión en una cuenta de Facebook con la función `login_facebook`.
-   **pagename**: nombre de la página
-   **n** : cantidad mínima de publicaciones a descargar
-   **reactions** si el valor es TRUE se retorna en un data.frame información sobre las reacciones de los usuario a la publicación
-   **comments** : si el valor es TRUE se retorna en un data.frame el contenido de los comentarios de la publicación
-   **shares** : si el valor es TRUE se retorna en un data.frame información sobre los usuarios que compartieron la publicación

Veamos algunos ejemplos :

Extraer las últimas 10 publicaciones de una pagina de Facebook
--------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 6
#> $ page_id    <chr> "265769886798719", "265769886798719", "26576988679871…
#> $ post_id    <chr> "2710460312329652", "2710430988999251", "271039755566…
#> $ post_text  <chr> "el sector expresó que nadie está pidiendo que no exi…
#> $ n_comments <int> 2, 0, 121, 16, 26, 28, 10, 5, 7, 604
#> $ n_shares   <int> 2, 0, 46, 10, 17, 4, 37, 4, 4, 503
#> $ date_time  <dttm> 2019-02-27 22:47:33, 2019-02-27 22:26:08, 2019-02-27…
```

La función `get_fb_post` retorna los siguiente valores.

-   **page\_id** : identificador único de la página
-   **post\_id** : identificador único de la publicación
-   **post\_text** : contenido del texto principal de la publicación
-   **n\_comments** : cantidad de comentarios
-   **n\_shares** : cantidad de compartidos
-   **date\_time** : hora y fecha en la que se realizó la publicación

Extraer las últimas 10 publicaciones de una pagina de Facebook e información sobre las reacciones de la publicación.
--------------------------------------------------------------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 13
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2710460312329652", "2710430988999251", "27103…
#> $ post_text         <chr> "el sector expresó que nadie está pidiendo que…
#> $ n_comments        <int> 2, 0, 121, 16, 26, 28, 10, 5, 7, 604
#> $ n_shares          <int> 2, 0, 46, 10, 17, 4, 37, 4, 4, 503
#> $ like              <int> 20, 10, 467, 41, 68, 30, 40, 50, 33, 183
#> $ love              <int> 1, 0, 72, 0, 2, 3, 2, 0, 0, 10
#> $ wow               <int> 0, 0, 30, 2, 9, 1, 24, 34, 0, 53
#> $ haha              <int> 0, 0, 268, 1, 2, 59, 1, 0, 13, 232
#> $ sad               <int> 0, 0, 56, 3, 11, 1, 161, 49, 2, 11
#> $ angry             <int> 0, 0, 10, 5, 1, 4, 1, 0, 0, 761
#> $ reactions_by_user <list> [<tbl_df[21 x 3]>, <tbl_df[10 x 3]>, NULL, <t…
#> $ date_time         <dttm> 2019-02-27 22:47:33, 2019-02-27 22:26:08, 201…
tibble::glimpse(df$reactions_by_user[[1]])
#> Observations: 21
#> Variables: 3
#> $ full_name     <chr> "Hazel Fernández Armador", "Johanna Miranda", "Mar…
#> $ user_name     <chr> "/hazel.fernandezarmador", "/johanna.miranda.3597"…
#> $ type_reaction <chr> "like", "like", "like", "like", "like", "like", "l…
```

La función `get_fb_post` retorna los siguiente valores.

-   **page\_id** : identificador único de la página
-   **post\_id** : identificador único de la publicación
-   **post\_text** : contenido del texto principal de la publicación
-   **n\_comments** : cantidad de comentarios
-   **n\_shares** : cantidad de compartidos
-   **like** : cantidad de "me gusta"
-   **love** : cantidad de "me encanta"
-   **wow** : cantidad de "me sorprende"
-   **haha** : cantidad de "me da risa"
-   **sad** : cantidad de "me entristece"
-   **angry** : cantidad de "me enoja"
-   **reactions\_by\_user** :
    -   **full\_name** : nombre real del usuario
    -   **username** : nombre de la cuenta del usuario
    -   **type\_reaction** : reacción hecha por el usuario
-   **date\_time** : hora y fecha en la que se realizó la publicación

Extraer las últimas 10 publicaciones de una pagina de Facebook, información sobre las reacciones y comentarios de la publicación.
---------------------------------------------------------------------------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T, commets = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 14
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2710460312329652", "2710430988999251", "27103…
#> $ post_text         <chr> "el sector expresó que nadie está pidiendo que…
#> $ n_comments        <int> 2, 0, 121, 16, 26, 29, 10, 5, 7, 604
#> $ n_shares          <int> 2, 0, 47, 10, 17, 4, 37, 4, 4, 506
#> $ like              <int> 22, 11, 472, 41, 69, 30, 40, 50, 33, 183
#> $ love              <int> 1, 0, 72, 0, 2, 3, 2, 0, 0, 10
#> $ wow               <int> 0, 0, 31, 2, 9, 1, 24, 34, 0, 53
#> $ haha              <int> 0, 0, 269, 1, 2, 59, 1, 0, 13, 232
#> $ sad               <int> 0, 0, 56, 3, 11, 1, 162, 49, 2, 11
#> $ angry             <int> 0, 0, 10, 5, 1, 4, 1, 0, 0, 764
#> $ reactions_by_user <list> [<tbl_df[23 x 3]>, <tbl_df[11 x 3]>, <tbl_df[…
#> $ comments          <list> [<tbl_df[2 x 3]>, NULL, <tbl_df[104 x 3]>, <t…
#> $ date_time         <dttm> 2019-02-27 22:47:33, 2019-02-27 22:26:08, 201…
```

La función `get_fb_post` retorna los siguiente valores.

-   **page\_id** : identificador único de la página
-   **post\_id** : identificador único de la publicación
-   **post\_text** : contenido del texto principal de la publicación
-   **n\_comments** : cantidad de comentarios
-   **n\_shares** : cantidad de compartidos
-   **like** : cantidad de "me gusta"
-   **love** : cantidad de "me encanta"
-   **wow** : cantidad de "me sorprende"
-   **haha** : cantidad de "me da risa"
-   **sad** : cantidad de "me entristece"
-   **angry** : cantidad de "me enoja"
-   **reactions\_by\_user** :
    -   **full\_name** : nombre del usuario
    -   **username** : nombre de la cuenta del usuario
    -   **type\_reaction** : reacción hecha por el usuario
-   **comments** :
    -   **full\_name** : nombre del usuario
    -   **user\_name** : nombre de la cuenta del usuario
    -   **text** : texto del comentario
-   **date\_time** : hora y fecha en la que se realizó la publicación

Extraer las últimas 10 publicaciones de una pagina de Facebook, información sobre las reacciones, comentarios de la publicación y los usuario que compartieron la publicación.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T, commets = T, shares = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 15
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2710460312329652", "2710430988999251", "27103…
#> $ post_text         <chr> "el sector expresó que nadie está pidiendo que…
#> $ n_comments        <int> 2, 0, 124, 17, 27, 29, 10, 5, 7, 605
#> $ n_shares          <int> 2, 0, 48, 11, 17, 4, 37, 4, 4, 509
#> $ like              <int> 27, 12, 481, 41, 69, 30, 40, 51, 33, 186
#> $ love              <int> 1, 0, 76, 0, 2, 3, 2, 0, 0, 10
#> $ wow               <int> 0, 0, 32, 2, 9, 1, 24, 35, 0, 53
#> $ haha              <int> 0, 0, 272, 1, 2, 60, 1, 0, 13, 234
#> $ sad               <int> 0, 0, 57, 3, 11, 1, 163, 49, 2, 11
#> $ angry             <int> 0, 0, 11, 5, 1, 4, 1, 0, 0, 772
#> $ reactions_by_user <list> [<tbl_df[28 x 3]>, <tbl_df[12 x 3]>, <tbl_df[…
#> $ comments          <list> [<tbl_df[2 x 3]>, NULL, <tbl_df[105 x 3]>, <t…
#> $ shares            <list> [NULL, NULL, <tbl_df[16 x 2]>, <tbl_df[4 x 2]…
#> $ date_time         <dttm> 2019-02-27 22:47:33, 2019-02-27 22:26:08, 201…
```

La función `get_fb_post` retorna los siguiente valores.

-   **page\_id** : identificador único de la página
-   **post\_id** : identificador único de la publicación
-   **post\_text** : contenido del texto principal de la publicación
-   **n\_comments** : cantidad de comentarios
-   **n\_shares** : cantidad de compartidos
-   **like** : cantidad de "me gusta"
-   **love** : cantidad de "me encanta"
-   **wow** : cantidad de "me sorprende"
-   **haha** : cantidad de "me da risa"
-   **sad** : cantidad de "me entristece"
-   **angry** : cantidad de "me enoja"
-   **reactions\_by\_user** :
    -   **full\_name** : nombre del usuario
    -   **username** : nombre de la cuenta del usuario
    -   **type\_reaction** : reacción hecha por el usuario
-   **comments** :
    -   **full\_name** : nombre del usuario
    -   **user\_name** : nombre de la cuenta del usuario
    -   **text** : texto del comentario
-   **shares** :
    -   **ful\_name** : nombre del usuario
    -   **user\_name** : nombre de la cuenta de usuario
-   **date\_time** : hora y fecha en la que se realizó la publicación

### Cerrar el servidor

``` r
stop_server(session)
#>  ✔ Se cerró con éxito el servidor de Selenium.
#> NULL
```

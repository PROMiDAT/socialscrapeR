
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
#> ✔ Se inició con éxito el servidor de Selenium en el puerto 4567.
```

Iniciar sesión en Facebook
--------------------------

    #> Se está redirigiendo el navegador a la url: https://m.facebook.com ...
    #> Se inición sesión en https://m.facebook.com con el usuario *****************

``` r
login_facebook(session, username = "<email>", password = "<password>")
```

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
#> $ post_id    <chr> "2710316119010738", "2710289569013393", "271026106234…
#> $ post_text  <chr> "deportes: tras la escandalosa goleada 5 a 1 frente a…
#> $ n_comments <int> 11, 5, 5, 7, 487, 396, 15, 295, 8, 82
#> $ n_shares   <int> 2, 24, 0, 3, 347, 81, 4, 189, 11, 11
#> $ date_time  <dttm> 2019-02-27 21:12:35, 2019-02-27 20:58:29, 2019-02-27…
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
#> $ post_id           <chr> "2710316119010738", "2710289569013393", "27102…
#> $ post_text         <chr> "deportes: tras la escandalosa goleada 5 a 1 f…
#> $ n_comments        <int> 11, 5, 5, 7, 487, 396, 15, 295, 8, 82
#> $ n_shares          <int> 2, 24, 0, 3, 347, 81, 4, 189, 11, 11
#> $ like              <int> 15, 30, 36, 25, 132, 920, 97, 191, 115, 651
#> $ love              <int> 2, 0, 0, 0, 10, 115, 9, 6, 2, 45
#> $ wow               <int> 0, 20, 24, 0, 45, 27, 3, 78, 1, 5
#> $ haha              <int> 32, 1, 0, 13, 176, 28, 11, 12, 2, 28
#> $ sad               <int> 1, 122, 31, 2, 7, 4, 0, 31, 0, 3
#> $ angry             <int> 1, 1, 0, 0, 584, 648, 0, 224, 0, 0
#> $ reactions_by_user <list> [<tbl_df[51 x 3]>, <tbl_df[174 x 3]>, <tbl_df…
#> $ date_time         <dttm> 2019-02-27 21:12:35, 2019-02-27 20:58:29, 201…
tibble::glimpse(df$reactions_by_user[[1]])
#> Observations: 51
#> Variables: 3
#> $ full_name     <chr> "Silvia Ajon Jiron", "Ricardo Ferraro", "Joseph Or…
#> $ user_name     <chr> "/silvia.ajonjiron", "/ricardo.ferraro.1671", "/jo…
#> $ type_reaction <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
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
#> $ post_id           <chr> "2710316119010738", "2710289569013393", "27102…
#> $ post_text         <chr> "deportes: tras la escandalosa goleada 5 a 1 f…
#> $ n_comments        <int> 11, 6, 5, 7, 491, 398, 15, 295, 8, 82
#> $ n_shares          <int> 2, 24, 0, 3, 353, 81, 4, 189, 11, 11
#> $ like              <int> 16, 30, 36, 25, 133, 924, 97, 191, 116, 651
#> $ love              <int> 2, 0, 0, 0, 10, 115, 9, 6, 2, 45
#> $ wow               <int> 0, 20, 24, 0, 46, 27, 3, 78, 1, 5
#> $ haha              <int> 32, 1, 0, 13, 181, 28, 11, 12, 2, 28
#> $ sad               <int> 1, 125, 32, 2, 7, 4, 0, 31, 0, 3
#> $ angry             <int> 1, 1, 0, 0, 589, 653, 0, 224, 0, 0
#> $ reactions_by_user <list> [<tbl_df[52 x 3]>, <tbl_df[178 x 3]>, <tbl_df…
#> $ comments          <list> [<tbl_df[6 x 3]>, <tbl_df[6 x 3]>, <tbl_df[4 …
#> $ date_time         <dttm> 2019-02-27 21:12:35, 2019-02-27 20:58:29, 201…
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

Extraer las últimas 10 publicaciones de una pagina de Facebook, información sobre las reacciones, comentarios de la publicación y los usuario que compartieron la aplicación.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10, reactions = T, commets = T, shares = T)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 15
#> $ page_id           <chr> "265769886798719", "265769886798719", "2657698…
#> $ post_id           <chr> "2710360732339610", "2710316119010738", "27102…
#> $ post_text         <chr> "tratarán de reubicarlos en otras empresas", "…
#> $ n_comments        <int> 1, 11, 6, 5, 7, 505, 404, 15, 297, 8
#> $ n_shares          <int> 2, 2, 24, 1, 3, 363, 82, 4, 190, 11
#> $ like              <int> 6, 16, 31, 38, 26, 138, 933, 98, 191, 116
#> $ love              <int> 0, 3, 1, 0, 0, 10, 116, 9, 6, 2
#> $ wow               <int> 1, 0, 21, 24, 0, 47, 28, 3, 78, 1
#> $ haha              <int> 1, 32, 1, 0, 13, 187, 31, 11, 12, 2
#> $ sad               <int> 1, 1, 127, 33, 2, 7, 5, 0, 31, 0
#> $ angry             <int> 0, 2, 1, 0, 0, 599, 660, 0, 228, 0
#> $ reactions_by_user <list> [<tbl_df[9 x 3]>, <tbl_df[54 x 3]>, <tbl_df[1…
#> $ comments          <list> [<tbl_df[2 x 3]>, <tbl_df[6 x 3]>, <tbl_df[6 …
#> $ shares            <list> [<tbl_df[2 x 2]>, <tbl_df[2 x 2]>, <tbl_df[7 …
#> $ date_time         <dttm> 2019-02-27 21:41:28, 2019-02-27 21:12:35, 201…
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
#> ✔ Se cerró con éxito el servidor de Selenium
```

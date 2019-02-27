
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

Descargar publicaciones de una pagina de FaceBook
-------------------------------------------------

    #> Se está redirigiendo el navegador a la url: https://m.facebook.com ...
    #> Se inición sesión en https://m.facebook.com con el usuario *****************

``` r
login_facebook(session, username = "email", password = "password")
```

Extraer las últimas 10 publicaciones de una pagina de Facebook
--------------------------------------------------------------

``` r
df <- get_fb_posts(session, pagename = "crhoy.comnoticias", n = 10)
#> Se está redirigiendo el navegador a la url: https://m.facebook.com/crhoy.comnoticias ...
tibble::glimpse(df)
#> Observations: 10
#> Variables: 6
#> $ page_id    <chr> "265769886798719", "265769886798719", "26576988679871…
#> $ post_id    <chr> "2710234982352185", "2710206715688345", "271017404235…
#> $ post_text  <chr> "video: américa goleó al pachuca por la copa mx", "la…
#> $ n_comments <int> 0, 163, 277, 14, 251, 8, 81, 171, 3, 115
#> $ n_shares   <int> 0, 94, 50, 2, 161, 10, 10, 30, 4, 78
#> $ date_time  <dttm> 2019-02-27 20:23:58, 2019-02-27 20:05:38, 2019-02-27…
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
#> $ post_id           <chr> "2710234982352185", "2710206715688345", "27101…
#> $ post_text         <chr> "video: américa goleó al pachuca por la copa m…
#> $ n_comments        <int> 0, 163, 277, 14, 251, 8, 81, 171, 3, 115
#> $ n_shares          <int> 0, 94, 50, 2, 161, 10, 10, 30, 4, 78
#> $ like              <int> 2, 48, 587, 80, 160, 112, 612, 435, 7, 105
#> $ love              <int> 0, 4, 75, 8, 6, 1, 45, 37, 0, 2
#> $ wow               <int> 0, 20, 20, 2, 74, 1, 5, 7, 0, 28
#> $ haha              <int> 1, 70, 20, 10, 11, 2, 24, 1, 0, 14
#> $ sad               <int> 0, 4, 3, 0, 26, 0, 3, 2, 0, 1
#> $ angry             <int> 0, 224, 431, 0, 195, 0, 0, 83, 0, 131
#> $ reactions_by_user <list> [<tbl_df[3 x 3]>, <tbl_df[373 x 3]>, <tbl_df[…
#> $ date_time         <dttm> 2019-02-27 20:23:58, 2019-02-27 20:05:38, 201…
tibble::glimpse(df$reactions_by_user[[1]])
#> Observations: 3
#> Variables: 3
#> $ full_name     <chr> "Dino Fierro", "Randall E. Sanchez", "Seferino Oro…
#> $ user_name     <chr> "/dino.fierro.71", "/randall.esquivelsanchez", "/s…
#> $ type_reaction <chr> NA, NA, NA
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
-   **sad** : cantidad de "me tristese"
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
#> $ post_id           <chr> "2710234982352185", "2710206715688345", "27101…
#> $ post_text         <chr> "video: américa goleó al pachuca por la copa m…
#> $ n_comments        <int> 0, 182, 280, 14, 252, 8, 81, 171, 3, 115
#> $ n_shares          <int> 0, 103, 51, 2, 162, 10, 10, 30, 4, 79
#> $ like              <int> 4, 52, 599, 83, 160, 112, 614, 435, 7, 105
#> $ love              <int> 0, 4, 76, 8, 6, 1, 45, 37, 0, 2
#> $ wow               <int> 0, 21, 23, 2, 74, 1, 5, 7, 0, 28
#> $ haha              <int> 1, 74, 20, 10, 11, 2, 24, 1, 0, 14
#> $ sad               <int> 0, 4, 3, 0, 26, 0, 3, 2, 0, 1
#> $ angry             <int> 0, 244, 438, 0, 195, 0, 0, 83, 0, 131
#> $ reactions_by_user <list> [<tbl_df[5 x 3]>, <tbl_df[399 x 3]>, <tbl_df[…
#> $ comments          <list> [<tbl_df[2 x 3]>, <tbl_df[170 x 3]>, <tbl_df[…
#> $ date_time         <dttm> 2019-02-27 20:23:58, 2019-02-27 20:05:38, 201…
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
-   **sad** : cantidad de "me tristese"
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
#> $ post_id           <chr> "2710234982352185", "2710206715688345", "27101…
#> $ post_text         <chr> "video: américa goleó al pachuca por la copa m…
#> $ n_comments        <int> 2, 211, 286, 14, 252, 8, 81, 171, 3, 115
#> $ n_shares          <int> 1, 121, 51, 2, 163, 10, 10, 30, 4, 80
#> $ like              <int> 7, 59, 614, 85, 162, 112, 617, 437, 8, 105
#> $ love              <int> 0, 4, 79, 8, 6, 1, 45, 38, 0, 2
#> $ wow               <int> 0, 22, 24, 2, 74, 1, 5, 7, 0, 28
#> $ haha              <int> 2, 83, 21, 10, 11, 2, 24, 1, 0, 14
#> $ sad               <int> 0, 4, 3, 0, 26, 0, 3, 2, 0, 1
#> $ angry             <int> 0, 271, 450, 0, 197, 0, 0, 83, 0, 132
#> $ reactions_by_user <list> [<tbl_df[9 x 3]>, <tbl_df[443 x 3]>, <tbl_df[…
#> $ comments          <list> [<tbl_df[4 x 3]>, <tbl_df[196 x 3]>, <tbl_df[…
#> $ shares            <list> [NULL, <tbl_df[30 x 2]>, <tbl_df[20 x 2]>, <t…
#> $ date_time         <dttm> 2019-02-27 20:23:58, 2019-02-27 20:05:38, 201…
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
-   **sad** : cantidad de "me tristese"
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

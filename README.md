
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
bot_facebook = fb_bot$new()
```

## Iniciar sesión en Facebook

``` r
bot_facebook$login(
  username = "******@gmai.com",
  password = "********")
```

Nota: Para evitar exponer tus credenciales en tu código se recomienda el
uso de paquete [keying](https://github.com/r-lib/keyring).

## Función `get_posts`

Esta función nos retorna un data.frame con la información de las últimas
`n` publicaciones de una página, esta función recibe los siguiente
parámetros:

  - x = una conexión con selenium creada con la función start\_server en
    la que ya se inicio sesión en una cuenta de Facebook con la función
    `login_facebook`.
  - **pagename**: nombre de la página
  - **n** : cantidad mínima de publicaciones a descargar
  - **reactions**: si el valor es TRUE se retorna en un data.frame
    información sobre las reacciones de los usuario a la publicación

Veamos algunos ejemplos
:

## Extraer las últimas 10 publicaciones de una pagina de Facebook

``` r
df <- bot_facebook$get_posts(pagename = "ameliarueda", n = 10, reactions = T)
tibble::glimpse(df)
#> Observations: 13
#> Variables: 12
#> $ page_id    <chr> "142921462922", "142921462922", "142921462922", "142921462…
#> $ post_id    <chr> "10158463330447923", "10158463292987923", "101584630863679…
#> $ text       <chr> "el jefe de la diplomacia de estados unidos llega hoy a co…
#> $ n_comments <dbl> 5, 1, 11, 1, 68, 0, 87, 11, 6, 39, 24, 76, 4
#> $ n_shares   <dbl> 1, 13, 1, 0, 11, 3, 662, 34, 2, 1, 9, 32, 4
#> $ like       <dbl> 8, 16, 3, 5, 143, 4, 438, 93, 35, 119, 65, 203, 13
#> $ love       <dbl> 0, 0, 0, 1, 18, 0, 10, 1, 0, 2, 0, 1, 2
#> $ wow        <dbl> 0, 11, 4, 0, 0, 11, 357, 28, 4, 0, 21, 30, 2
#> $ haha       <dbl> 2, 0, 2, 5, 10, 0, 5, 1, 3, 0, 2, 1, 12
#> $ sad        <dbl> 0, 2, 2, 0, 0, 7, 48, 7, 3, 0, 0, 13, 0
#> $ angry      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
#> $ date_time  <dttm> 2020-01-21 15:17:27, 2020-01-21 15:05:39, 2020-01-21 13:4…
```

La función `get_posts` retorna los siguiente valores.

  - **page\_id** : identificador único de la página
  - **post\_id** : identificador único de la publicación
  - **text** : contenido del texto principal de la publicación
  - **n\_comments** : cantidad de comentarios
  - **n\_shares** : cantidad de compartidos
  - **like**: cantidad de me gusta
  - **love**: cantidad de me encanta
  - **wow**: cantidad de me sorprende
  - **haha**: cantidad de risas
  - **sad**: cantidad de me entristece
  - **angry**: cantidad de me enoja
  - **date\_time** : hora y fecha en la que se realizó la publicación

## Comentarios de una publicación en especifico

Para estraer los comentarios de una publicación debemos indicar el id de
la página y el id de la publicación que queremos analizar.

``` r

comentarios <- bot_facebook$get_comments(page_id = "142921462922", post_id = "10158463086367923")
tibble::glimpse(comentarios)
#> List of 1
#>  $ :Classes 'tbl_df', 'tbl' and 'data.frame':    11 obs. of  5 variables:
#>   ..$ page_id  : chr [1:11] "142921462922" "142921462922" "142921462922" "142921462922" ...
#>   ..$ post_id  : chr [1:11] "10158463086367923" "10158463086367923" "10158463086367923" "10158463086367923" ...
#>   ..$ full_name: chr [1:11] "Sergio Cam" "Eliomar Vargas" "Sergio Cam" "Raúl Buendía" ...
#>   ..$ user_name: chr [1:11] "/sergio.camposbarquero" "/eliomar.vargas2" "/sergio.camposbarquero" "/raul.buendiaurena" ...
#>   ..$ text     : chr [1:11] "suponiendo que son 1386 millones de personas, 300 infectados es el 0,00021 de la población, por lo que la tasa "| __truncated__ "sergio cam pero cual de las dos tiene mas potencial de expansión?" "eliomar vargas el hambre evidentemente! hay muertos por hambre en todo el mundo! y ni se diga la escasez de agua!" "sergio cam el hambre es un problema endémico en ciertas zonas del mundo, relacionada con problemas estructurale"| __truncated__ ...
```

La función `get_comments` retorna los siguiente valores

  - **page\_id**: identificador de la página
  - **post\_id**: identificador de la publicación
  - **full\_name**: nombre del usuario que realizó el comentario
  - **user\_name**: nombre de usuario (único) que realizó el comentario
  - **text**: texto del comentario

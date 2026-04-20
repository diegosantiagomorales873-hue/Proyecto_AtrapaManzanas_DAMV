application =
{
    content =
    {
        width = 768,      -- Resolución base más alta (ideal para tablets)
        height = 1024,    -- Proporción estándar de iPad/Android Tablets
        scale = "letterBox", -- Ajusta el juego sin estirar las imágenes
        fps = 60,
        
        imageSuffix =
        {
            ["@2x"] = 1.5, -- Para pantallas de alta definición
            ["@4x"] = 3.0, -- Para pantallas Retina o tablets Pro
        },
    },
}

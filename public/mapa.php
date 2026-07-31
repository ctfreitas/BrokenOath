<?php
$envPath = __DIR__ . '/../.env';
$env = file_exists($envPath) ? parse_ini_file($envPath) : [];

$supabaseUrl = $env['SUPABASE_URL'] ?? '';
$supabaseAnonKey = $env['SUPABASE_ANON_KEY'] ?? '';
$configured = $supabaseUrl !== '' && $supabaseAnonKey !== '';
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Broken Oath — Mapa</title>

    <style>
        :root {
            --barra-altura: 54px;
            --ouro: #d8b56a;
            --ouro-claro: #f0d89a;
            --fundo-escuro: rgba(18, 14, 11, 0.94);
            --borda: rgba(216, 181, 106, 0.48);
            --texto: #f6edd9;
            --texto-fraco: #c9bea9;
        }

        * {
            box-sizing: border-box;
        }

        html,
        body {
            width: 100%;
            height: 100%;
            margin: 0;
            overflow: hidden;
            background: #090806;
            color: var(--texto);
            font-family: Georgia, "Times New Roman", serif;
        }

        button,
        a {
            font: inherit;
        }

        .topbar {
            position: fixed;
            inset: 0 0 auto 0;
            z-index: 100;
            height: var(--barra-altura);
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 12px;
            background: linear-gradient(180deg, rgba(30, 23, 17, 0.98), rgba(15, 12, 9, 0.94));
            border-bottom: 1px solid var(--borda);
            box-shadow: 0 5px 18px rgba(0, 0, 0, 0.5);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 9px;
            min-width: 178px;
            margin-right: auto;
            color: var(--ouro-claro);
            text-decoration: none;
        }

        .brand img {
            width: 38px;
            height: 38px;
            object-fit: contain;
        }

        .brand strong {
            display: block;
            font-size: 19px;
            letter-spacing: 0.7px;
        }

        .brand span {
            display: block;
            margin-top: 2px;
            color: var(--texto-fraco);
            font-size: 11px;
        }

        .info-box,
        .top-button {
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 5px 12px;
            border: 1px solid var(--borda);
            border-radius: 5px;
            background: rgba(60, 45, 31, 0.48);
            color: var(--texto);
            white-space: nowrap;
        }

        .info-box {
            flex-direction: column;
            align-items: flex-start;
            min-width: 130px;
        }

        .info-label {
            color: var(--texto-fraco);
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }

        .info-value {
            max-width: 190px;
            overflow: hidden;
            color: var(--ouro-claro);
            font-size: 14px;
            text-overflow: ellipsis;
        }

        .top-button {
            cursor: pointer;
            text-decoration: none;
            transition: border-color 160ms ease, background 160ms ease, transform 160ms ease;
        }

        .top-button:hover,
        .top-button:focus-visible {
            border-color: var(--ouro-claro);
            background: rgba(111, 78, 40, 0.68);
            outline: none;
            transform: translateY(-1px);
        }

        .city-button {
            min-width: 190px;
            color: var(--ouro-claro);
            font-weight: bold;
        }

        .menu-button {
            width: 90px;
            font-weight: bold;
        }

        .map-viewport {
            position: fixed;
            inset: var(--barra-altura) 0 0;
            overflow: hidden;
            background: #080806;
            cursor: grab;
            touch-action: none;
            user-select: none;
        }

        .map-viewport.dragging {
            cursor: grabbing;
        }

        .map-stage {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            transform-origin: 0 0;
            will-change: transform;
        }

        .world-map {
            position: absolute;
            left: 0;
            top: 0;
            display: block;
            width: 100%;
            height: 100%;
            object-fit: fill;
            pointer-events: none;
            -webkit-user-drag: none;
        }

        .map-layer {
            position: absolute;
            inset: 0;
            pointer-events: none;
        }
        .city-marker {
            position: absolute;
            z-index: 10;
            display: block;
            width: 56px;
            height: auto;
            object-fit: contain;
            transform: translate(-50%, -100%);
            transform-origin: center bottom;
            pointer-events: none;
            user-select: none;
            -webkit-user-drag: none;
        }

        .city-marker[data-level="1"] {
            width: 42px;
        }

        .city-marker[data-level="2"] {
            width: 48px;
        }

        .city-marker[data-level="3"] {
            width: 56px;
        }

        .city-marker[data-level="4"] {
            width: 60px;
        }

        .city-marker[data-level="5"] {
            width: 72px;
        }

        .map-controls {
            position: fixed;
            right: 14px;
            bottom: 16px;
            z-index: 80;
            display: grid;
            gap: 7px;
        }

        .map-control {
            width: 42px;
            height: 42px;
            border: 1px solid var(--borda);
            border-radius: 5px;
            background: var(--fundo-escuro);
            color: var(--ouro-claro);
            cursor: pointer;
            font-size: 21px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .map-control:hover,
        .map-control:focus-visible {
            border-color: var(--ouro-claro);
            outline: none;
        }

        .coordinates {
            position: fixed;
            left: 14px;
            bottom: 16px;
            z-index: 80;
            min-width: 126px;
            padding: 9px 12px;
            border: 1px solid var(--borda);
            border-radius: 5px;
            background: var(--fundo-escuro);
            color: var(--ouro-claro);
            font-size: 14px;
            letter-spacing: 0.4px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .status {
            position: fixed;
            left: 50%;
            top: calc(var(--barra-altura) + 16px);
            z-index: 120;
            max-width: min(620px, calc(100vw - 32px));
            padding: 10px 15px;
            border: 1px solid rgba(190, 75, 60, 0.75);
            border-radius: 5px;
            background: rgba(54, 18, 14, 0.94);
            color: #ffe3dc;
            text-align: center;
            transform: translateX(-50%);
        }

        .loading {
            position: fixed;
            inset: var(--barra-altura) 0 0;
            z-index: 70;
            display: grid;
            place-items: center;
            background: #090806;
            color: var(--ouro-claro);
            font-size: 18px;
        }

        .loading[hidden],
        .status[hidden] {
            display: none;
        }
.coordinate-search {
    position: fixed;
    right: 70px;
    bottom: 16px;
    z-index: 80;
    display: flex;
    gap: 6px;
    padding: 7px;
    border: 1px solid var(--borda);
    border-radius: 5px;
    background: var(--fundo-escuro);
}

.coordinate-search input {
    width: 68px;
    padding: 7px;
    border: 1px solid var(--borda);
    border-radius: 4px;
    background: #17120d;
    color: var(--texto);
}

.coordinate-search button {
    padding: 7px 14px;
    border: 1px solid var(--borda);
    border-radius: 4px;
    background: rgba(111, 78, 40, 0.68);
    color: var(--ouro-claro);
    cursor: pointer;
}
        @media (max-width: 900px) {
            :root {
                --barra-altura: 118px;
            }

            .topbar {
                flex-wrap: wrap;
                align-content: center;
                gap: 6px;
            }

            .brand {
                width: 100%;
                min-width: 0;
            }

            .brand span {
                display: none;
            }

            .info-box {
                min-width: 0;
                flex: 1;
            }

            .info-value {
                max-width: 145px;
            }

            .city-button,
            .top-button {
                min-width: auto;
            }
        }
    </style>
</head>
<body>
    <header class="topbar">
        <a class="brand" href="dashboard.php" aria-label="Voltar ao painel principal">
            <img src="assets/logo.png" alt="Brasão Broken Oath">
            <div>
                <strong>Broken Oath</strong>
                <span>Terras, poder e juramentos</span>
            </div>
        </a>

        <div class="info-box" aria-label="Mundo ativo">
            <span class="info-label">Mundo</span>
            <span id="world-name" class="info-value">Carregando...</span>
        </div>

        <div class="info-box" aria-label="Governador ativo">
            <span class="info-label">Governador</span>
            <span id="governor-name" class="info-value">Carregando...</span>
        </div>

        <a id="city-button" class="top-button city-button" href="cidade.php">
            Ir para&nbsp;<span id="city-name">Carregando...</span>
        </a>

        <a class="top-button menu-button" href="dashboard.php">Menu</a>
    </header>

    <main id="map-viewport" class="map-viewport" aria-label="Mapa do Mundo Alfa">
        <div id="map-stage" class="map-stage">
            <img
                id="world-map"
                class="world-map"
                alt="Mapa do Mundo Alfa"
                draggable="false"
            >

            <!-- Cidades, tropas e demais elementos serão inseridos nesta camada. -->
            <div id="map-layer" class="map-layer" aria-hidden="true"></div>
        </div>
    </main>

    <div id="coordinates" class="coordinates">X: -- &nbsp; Y: --</div>
        <div class="coordinate-search">
        <input id="go-x" type="number" min="1" placeholder="X">
        <input id="go-y" type="number" min="1" placeholder="Y">
        <button id="go-coordinate" type="button">Ir</button>
    </div>
    <div class="map-controls" aria-label="Controles do mapa">
        <button id="zoom-in" class="map-control" type="button" title="Aproximar" aria-label="Aproximar">+</button>
        <button id="zoom-out" class="map-control" type="button" title="Afastar" aria-label="Afastar">−</button>
        <button id="reset-map" class="map-control" type="button" title="Centralizar mapa" aria-label="Centralizar mapa">⌂</button>
    </div>

    <div id="loading" class="loading">Abrindo o mapa do reino...</div>
    <div id="status" class="status" role="alert" hidden></div>

    <script>
        window.BROKEN_OATH_CONFIG = <?= json_encode([
            'supabaseUrl' => $supabaseUrl,
            'supabaseAnonKey' => $supabaseAnonKey,
            'configured' => $configured,
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

    <script>
        (() => {
            'use strict';

            const LOGICAL_WIDTH_DEFAULT = 200;
            const LOGICAL_HEIGHT_DEFAULT = 200;
            const STORAGE_CITY_ID = 'broken_oath_governante_ativo_id';
            const STORAGE_WORLD_ID = 'broken_oath_world_ativo_id';

            const config = window.BROKEN_OATH_CONFIG || {};
            const viewport = document.getElementById('map-viewport');
            const stage = document.getElementById('map-stage');
            const mapImage = document.getElementById('world-map');
            const mapLayer = document.getElementById('map-layer');
            const loading = document.getElementById('loading');
            const statusBox = document.getElementById('status');
            const worldName = document.getElementById('world-name');
            const governorName = document.getElementById('governor-name');
            const cityName = document.getElementById('city-name');
            const cityButton = document.getElementById('city-button');
            const coordinates = document.getElementById('coordinates');

            let client = null;
            let logicalWidth = LOGICAL_WIDTH_DEFAULT;
            let logicalHeight = LOGICAL_HEIGHT_DEFAULT;
            let currentMapPath = '';

            let scale = 1;
            let minScale = 1;
            let maxScale = 4;
            let translateX = 0;
            let translateY = 0;

            let dragging = false;
            let dragStartX = 0;
            let dragStartY = 0;
            let dragOriginX = 0;
            let dragOriginY = 0;

            const showError = (message) => {
                statusBox.textContent = message;
                statusBox.hidden = false;
                loading.hidden = true;
            };

            const hideError = () => {
                statusBox.hidden = true;
                statusBox.textContent = '';
            };
            const playerCityImages = {
                1: 'assets/mapa/baronato.png',
                2: 'assets/mapa/viscondado.png',
                3: 'assets/mapa/condado.png',
                4: 'assets/mapa/marca.png',
                5: 'assets/mapa/ducado.png'
            };

            const mercImages = {
                1: 'assets/mapa/npc_merc_n1.png',
                2: 'assets/mapa/npc_merc_n2.png',
                3: 'assets/mapa/npc_merc_n3.png',
                4: 'assets/mapa/npc_merc_n4.png',
                5: 'assets/mapa/npc_merc_n5.png'
            };

            const paciImages = {
                1: 'assets/mapa/npc_paci_n1.png',
                2: 'assets/mapa/npc_paci_n2.png',
                3: 'assets/mapa/npc_paci_n3.png',
                4: 'assets/mapa/npc_paci_n4.png',
                5: 'assets/mapa/npc_paci_n5.png'
            };

            const barbImages = {
                1: 'assets/mapa/npc_barb_n1.png',
                2: 'assets/mapa/npc_barb_n2.png',
                3: 'assets/mapa/npc_barb_n3.png',
                4: 'assets/mapa/npc_barb_n4.png',
                5: 'assets/mapa/npc_barb_n5.png'
            };

            function getCityImage(city, level) {

                if (city.tipo_entidade === 'reino') {
                    return 'assets/mapa/reinado.png';
                }

                if (city.tipo_entidade === 'fundacao') {
                    return 'assets/mapa/fundacao.png';
                }

                if (city.tipo_entidade === 'npc') {

                    switch ((city.perfil_cidade || '').toLowerCase()) {

                        case 'mercantil':
                            return mercImages[level];

                        case 'pacificadora':
                            return paciImages[level];

                        case 'conquistadora':
                            return barbImages[level];

                        default:
                            return barbImages[level];
                    }
                }

                return playerCityImages[level];
}

const getCityLevel = (levelValue) => {
    const normalized = String(levelValue || '')
        .trim()
        .toLowerCase();

    const levelsByName = {
        '1': 1,
        'baronato': 1,
        'baroneio': 1,

        '2': 2,
        'viscondado': 2,

        '3': 3,
        'condado': 3,

        '4': 4,
        'marca': 4,

        '5': 5,
        'ducado': 5
    };

    return levelsByName[normalized] || 1;
};

const renderCities = (coordinatesList) => {
    mapLayer.replaceChildren();

    for (const coordinate of coordinatesList || []) {
        const city = coordinate.cidades;
        const map = coordinate.mapa_coordenadas;

        if (!map) {
            continue;
        }

        const logicalX = Number(map.x);
        const logicalY = Number(map.y);

        if (
            !Number.isFinite(logicalX) ||
            !Number.isFinite(logicalY)
        ) {
            continue;
        }

        const isFoundation =
            !city &&
            String(coordinate.codigo_local || '').startsWith('FUND_');

        let level = 1;
        let imagePath = '';
        let markerAlt = '';

        if (isFoundation) {
            imagePath = 'assets/mapa/fundacao.png';
            markerAlt = `Fundação ${coordinate.categoria || ''}`;
        } else if (city) {
            level = getCityLevel(city.nivel_cidade);
            imagePath = getCityImage(city, level);
            markerAlt = `${city.nome_cidade || 'Cidade'} — nível ${level}`;
        } else {
            continue;
        }

        const offsetX = Number(map.sprite_offset_x) || 0;
        const offsetY = Number(map.sprite_offset_y) || 0;

        const marker = document.createElement('img');

        marker.src = imagePath;
        marker.alt = markerAlt;
        marker.className = 'city-marker';
        marker.dataset.level = String(level);

        if (isFoundation) {
            marker.dataset.type = 'foundation';
        }

        marker.style.left =
            `${(logicalX / logicalWidth) * 100}%`;

        marker.style.top =
            `${(logicalY / logicalHeight) * 100}%`;

        marker.style.marginLeft = `${offsetX}px`;
        marker.style.marginTop = `${offsetY}px`;

        const spriteWidth = Number(map.sprite_width);
        const spriteHeight = Number(map.sprite_height);

        if (Number.isFinite(spriteWidth) && spriteWidth > 0) {
            marker.style.width = `${spriteWidth}px`;
        }

        if (Number.isFinite(spriteHeight) && spriteHeight > 0) {
            marker.style.height = `${spriteHeight}px`;
        } else {
            marker.style.height = 'auto';
        }

        marker.addEventListener('error', () => {
            console.error(`Imagem não encontrada: ${imagePath}`);
            marker.remove();
        });

        mapLayer.appendChild(marker);
    }
};

            const getMapBaseSize = () => ({
                width: viewport.clientWidth,
                height: viewport.clientHeight
            });

            const clampTranslation = () => {
                const base = getMapBaseSize();
                const scaledWidth = base.width * scale;
                const scaledHeight = base.height * scale;

                const minX = Math.min(0, viewport.clientWidth - scaledWidth);
                const minY = Math.min(0, viewport.clientHeight - scaledHeight);

                translateX = Math.min(0, Math.max(minX, translateX));
                translateY = Math.min(0, Math.max(minY, translateY));
            };

            const renderTransform = () => {
                clampTranslation();
                stage.style.transform = `translate3d(${translateX}px, ${translateY}px, 0) scale(${scale})`;
            };

            const resetMap = () => {
                scale = minScale;
                translateX = 0;
                translateY = 0;
                renderTransform();
            };

            const zoomAt = (nextScale, clientX, clientY) => {
                const boundedScale = Math.min(maxScale, Math.max(minScale, nextScale));

                if (boundedScale === scale) {
                    return;
                }

                const rect = viewport.getBoundingClientRect();
                const pointerX = clientX - rect.left;
                const pointerY = clientY - rect.top;
                const mapX = (pointerX - translateX) / scale;
                const mapY = (pointerY - translateY) / scale;

                scale = boundedScale;
                translateX = pointerX - (mapX * scale);
                translateY = pointerY - (mapY * scale);
                renderTransform();
            };

            const updateCoordinates = (event) => {
                const rect = viewport.getBoundingClientRect();
                const localX = event.clientX - rect.left;
                const localY = event.clientY - rect.top;
                const mapX = (localX - translateX) / scale;
                const mapY = (localY - translateY) / scale;
                const base = getMapBaseSize();

                if (mapX < 0 || mapY < 0 || mapX > base.width || mapY > base.height) {
                    coordinates.innerHTML = 'X: -- &nbsp; Y: --';
                    return;
                }

                const logicalX = Math.min(
                    logicalWidth,
                    Math.max(1, Math.floor((mapX / base.width) * logicalWidth) + 1)
                );
                const logicalY = Math.min(
                    logicalHeight,
                    Math.max(1, Math.floor((mapY / base.height) * logicalHeight) + 1)
                );

                coordinates.textContent = `X: ${logicalX}   Y: ${logicalY}`;
            };

            const loadGameData = async () => {
                if (!config.configured || !window.supabase) {
                    showError('Supabase não configurado. Verifique o arquivo .env.');
                    return;
                }

                const AUTH_REMEMBER_KEY = 'broken_oath_lembrar_login';

                const authStorage = {
                    getItem(key) {
                        const remember =
                            localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

                        return remember
                            ? localStorage.getItem(key)
                            : sessionStorage.getItem(key);
                    },

                    setItem(key, value) {
                        const remember =
                            localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

                        if (remember) {
                            localStorage.setItem(key, value);
                            sessionStorage.removeItem(key);
                        } else {
                            sessionStorage.setItem(key, value);
                            localStorage.removeItem(key);
                        }
                    },

                    removeItem(key) {
                        localStorage.removeItem(key);
                        sessionStorage.removeItem(key);
                    }
                };

                client = window.supabase.createClient(
                    config.supabaseUrl,
                    config.supabaseAnonKey,
                    {
                        auth: {
                            storage: authStorage,
                            persistSession: true,
                            autoRefreshToken: true,
                            detectSessionInUrl: true
                        }
                    }
);

                const { data: sessionData, error: sessionError } = await client.auth.getSession();

                if (sessionError || !sessionData.session) {
                    window.location.replace('index.php');
                    return;
                }

                const user = sessionData.session.user;
                const activeCityId = localStorage.getItem(STORAGE_CITY_ID);
                const activeWorldId = localStorage.getItem(STORAGE_WORLD_ID);

                if (!activeCityId || !activeWorldId) {
                    window.location.replace('dashboard.php');
                    return;
                }

                const { data: city, error: cityError } = await client
                    .from('cidades')
                    .select('id, user_id, world_id, nome_governante, nome_cidade, titulo_governante, nivel_cidade, perfil_cidade, tipo_entidade')
                    .eq('id', activeCityId)
                    .eq('world_id', activeWorldId)
                    .eq('user_id', user.id)
                    .maybeSingle();

                if (cityError || !city) {
                    console.error('Erro ao carregar cidade ativa:', cityError);

                    showError(
                        'Não foi possível carregar a cidade ativa. Volte ao Menu e selecione novamente.'
                    );

                    return;
                }

                const { data: world, error: worldError } = await client
                    .from('worlds')
                    .select('id, nome, largura_mapa, altura_mapa, imagem_mapa')
                    .eq('id', activeWorldId)
                    .maybeSingle();

                if (worldError || !world) {
                    showError('Não foi possível carregar os dados do mundo ativo.');
                    return;
                }

                logicalWidth = Number(world.largura_mapa) || LOGICAL_WIDTH_DEFAULT;
                logicalHeight = Number(world.altura_mapa) || LOGICAL_HEIGHT_DEFAULT;

                worldName.textContent = world.nome || 'Terras Antigas';
                governorName.textContent = city.nome_governante || 'Governador';
                cityName.textContent = city.nome_cidade || 'Minha Cidade';
                cityButton.href = `cidade.php?id=${encodeURIComponent(city.id)}`;

                if (world.imagem_mapa && typeof world.imagem_mapa === 'string') {
    mapImage.src = world.imagem_mapa;
}

const {
    data: cityCoordinates,
    error: cityCoordinatesError
} = await client
    .from('locais_mapa')
    .select(`
        mapa_id,
        cidade_id,
        codigo_local,
        categoria,
        tipo_local,
        regiao,
        mapa_coordenadas!inner (
            x,
            y,
            sprite_offset_x,
            sprite_offset_y,
            sprite_width,
            sprite_height,
            world_id
        ),
        cidades (
            id,
            world_id,
            nome_cidade,
            nome_governante,
            nivel_cidade,
            perfil_cidade,
            tipo_entidade
        )
    `)
    .eq('mapa_coordenadas.world_id', activeWorldId)
    .or('cidade_id.not.is.null,codigo_local.like.FUND_%');

if (cityCoordinatesError) {
    console.error(cityCoordinatesError);

    showError(
        'O mapa foi carregado, mas não foi possível carregar as cidades e fundações.'
    );

    return;
}

console.log(cityCoordinates);
renderCities(cityCoordinates);
console.log(mapLayer.innerHTML);

hideError();
            };

            mapImage.addEventListener('load', () => {
                loading.hidden = true;
                resetMap();
            });

            mapImage.addEventListener('error', () => {
                const path = currentMapPath || 'caminho não informado';
                showError(`A imagem do mapa não foi encontrada em ${path}.`);
            });

            viewport.addEventListener('wheel', (event) => {
                event.preventDefault();
                const factor = event.deltaY < 0 ? 1.14 : 0.88;
                zoomAt(scale * factor, event.clientX, event.clientY);
            }, { passive: false });

            viewport.addEventListener('pointerdown', (event) => {
                if (event.button !== 0) {
                    return;
                }

                dragging = true;
                dragStartX = event.clientX;
                dragStartY = event.clientY;
                dragOriginX = translateX;
                dragOriginY = translateY;
                viewport.classList.add('dragging');
                viewport.setPointerCapture(event.pointerId);
            });

            viewport.addEventListener('pointermove', (event) => {
                updateCoordinates(event);

                if (!dragging) {
                    return;
                }

                translateX = dragOriginX + (event.clientX - dragStartX);
                translateY = dragOriginY + (event.clientY - dragStartY);
                renderTransform();
            });

            const stopDragging = (event) => {
                dragging = false;
                viewport.classList.remove('dragging');

                if (event.pointerId !== undefined && viewport.hasPointerCapture(event.pointerId)) {
                    viewport.releasePointerCapture(event.pointerId);
                }
            };

            viewport.addEventListener('pointerup', stopDragging);
            viewport.addEventListener('pointercancel', stopDragging);
            viewport.addEventListener('pointerleave', (event) => {
                coordinates.innerHTML = 'X: -- &nbsp; Y: --';

                if (dragging && event.buttons === 0) {
                    stopDragging(event);
                }
            });

            document.getElementById('zoom-in').addEventListener('click', () => {
                const rect = viewport.getBoundingClientRect();
                zoomAt(scale * 1.2, rect.left + rect.width / 2, rect.top + rect.height / 2);
            });

            document.getElementById('zoom-out').addEventListener('click', () => {
                const rect = viewport.getBoundingClientRect();
                zoomAt(scale * 0.82, rect.left + rect.width / 2, rect.top + rect.height / 2);
            });

            document.getElementById('reset-map').addEventListener('click', resetMap);

            document.getElementById('go-coordinate').addEventListener('click', () => {
    const x = Number(document.getElementById('go-x').value);
    const y = Number(document.getElementById('go-y').value);

    if (
        !Number.isFinite(x) ||
        !Number.isFinite(y) ||
        x < 1 ||
        y < 1 ||
        x > logicalWidth ||
        y > logicalHeight
    ) {
        alert(`Use coordenadas entre 1 e ${logicalWidth} para X e 1 e ${logicalHeight} para Y.`);
        return;
    }

    const base = getMapBaseSize();

    const mapPixelX = (x / logicalWidth) * base.width;
    const mapPixelY = (y / logicalHeight) * base.height;

    scale = Math.max(minScale, Math.min(maxScale, 2));

    translateX = (viewport.clientWidth / 2) - (mapPixelX * scale);
    translateY = (viewport.clientHeight / 2) - (mapPixelY * scale);

    renderTransform();
});

            window.addEventListener('resize', resetMap);

            loadGameData().catch((error) => {
                console.error(error);
                showError('Ocorreu um erro inesperado ao abrir o mapa.');
            });
        })();
    </script>
</body>
</html>
<?php

declare(strict_types=1);

const LARGURA = 100;
const ALTURA = 100;
const SEED = 12345;

function interpolar(float $a, float $b, float $valor): float
{
    $suave = $valor * $valor * (3 - 2 * $valor);

    return $a + ($b - $a) * $suave;
}

function valorAleatorio(int $x, int $y, int $seed): float
{
    $numero = sin(
        ($x * 127.1) +
        ($y * 311.7) +
        ($seed * 74.7)
    ) * 43758.5453;

    return $numero - floor($numero);
}

function ruido(
    float $x,
    float $y,
    int $seed
): float {
    $xInicial = (int) floor($x);
    $yInicial = (int) floor($y);

    $xFinal = $xInicial + 1;
    $yFinal = $yInicial + 1;

    $fracaoX = $x - $xInicial;
    $fracaoY = $y - $yInicial;

    $superiorEsquerdo = valorAleatorio(
        $xInicial,
        $yInicial,
        $seed
    );

    $superiorDireito = valorAleatorio(
        $xFinal,
        $yInicial,
        $seed
    );

    $inferiorEsquerdo = valorAleatorio(
        $xInicial,
        $yFinal,
        $seed
    );

    $inferiorDireito = valorAleatorio(
        $xFinal,
        $yFinal,
        $seed
    );

    $superior = interpolar(
        $superiorEsquerdo,
        $superiorDireito,
        $fracaoX
    );

    $inferior = interpolar(
        $inferiorEsquerdo,
        $inferiorDireito,
        $fracaoX
    );

    return interpolar(
        $superior,
        $inferior,
        $fracaoY
    );
}

function ruidoEmCamadas(
    int $x,
    int $y,
    int $seed
): float {
    $resultado = 0;
    $pesoTotal = 0;

    $camadas = [
        ['escala' => 45, 'peso' => 1.00],
        ['escala' => 22, 'peso' => 0.50],
        ['escala' => 10, 'peso' => 0.25],
    ];

    foreach ($camadas as $indice => $camada) {
        $valor = ruido(
            $x / $camada['escala'],
            $y / $camada['escala'],
            $seed + $indice
        );

        $resultado += $valor * $camada['peso'];
        $pesoTotal += $camada['peso'];
    }

    return $resultado / $pesoTotal;
}

function definirTerreno(
    float $elevacao,
    float $umidade
): string {
    if ($elevacao < 0.30) {
        return 'agua';
    }

    if ($elevacao < 0.36) {
        return 'praia';
    }

    if ($elevacao > 0.82) {
        return 'montanha';
    }

    if ($elevacao > 0.72) {
        return 'colina';
    }

    if ($umidade > 0.62) {
        return 'floresta';
    }

    return 'planicie';
}

$mapa = [];
$quantidades = [];

for ($y = 1; $y <= ALTURA; $y++) {
    for ($x = 1; $x <= LARGURA; $x++) {
        $elevacao = ruidoEmCamadas(
            $x,
            $y,
            SEED
        );

        $umidade = ruidoEmCamadas(
            $x,
            $y,
            SEED + 5000
        );

        $terreno = definirTerreno(
            $elevacao,
            $umidade
        );

        $mapa[] = [
            'x' => $x,
            'y' => $y,
            'tipo_terreno' => $terreno,
            'elevacao' => round($elevacao, 4),
            'umidade' => round($umidade, 4),
        ];

        $quantidades[$terreno] =
            ($quantidades[$terreno] ?? 0) + 1;
    }
}

file_put_contents(
    __DIR__ . '/mapa_teste.json',
    json_encode(
        $mapa,
        JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE
    )
);

echo '<h1>Mapa gerado com sucesso</h1>';
echo '<p>Seed: ' . SEED . '</p>';
echo '<p>Total: ' . count($mapa) . ' coordenadas</p>';

echo '<pre>';
print_r($quantidades);
echo '</pre>';
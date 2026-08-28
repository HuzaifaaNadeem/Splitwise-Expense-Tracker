param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

# ASCII-only script.
# Broken character sequences are built from Unicode code points so the
# script itself cannot be damaged by text encoding differences.

function New-TextFromCodePoints {
    param([int[]]$CodePoints)

    $builder = New-Object System.Text.StringBuilder

    foreach ($codePoint in $CodePoints) {
        [void]$builder.Append([char]$codePoint)
    }

    return $builder.ToString()
}

$badBullet = New-TextFromCodePoints @(0x00E2, 0x20AC, 0x00A2)
$badEnDash = New-TextFromCodePoints @(0x00E2, 0x20AC, 0x201C)
$badEmDash = New-TextFromCodePoints @(0x00E2, 0x20AC, 0x201D)
$badArrow = New-TextFromCodePoints @(0x00E2, 0x2020, 0x2019)
$badGreaterEqual = New-TextFromCodePoints @(0x00E2, 0x2030, 0x00A5)
$badLessEqual = New-TextFromCodePoints @(0x00E2, 0x2030, 0x00A4)
$badNbspPrefix = New-TextFromCodePoints @(0x00C2, 0x00A0)

$replacements = @(
    [PSCustomObject]@{ Bad = $badBullet;       Good = " | "  },
    [PSCustomObject]@{ Bad = $badEnDash;       Good = " - "  },
    [PSCustomObject]@{ Bad = $badEmDash;       Good = " - "  },
    [PSCustomObject]@{ Bad = $badArrow;        Good = " -> " },
    [PSCustomObject]@{ Bad = $badGreaterEqual; Good = ">="   },
    [PSCustomObject]@{ Bad = $badLessEqual;    Good = "<="   },
    [PSCustomObject]@{ Bad = $badNbspPrefix;   Good = " "    }
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$files = Get-ChildItem -Path $Root -Recurse -File |
    Where-Object {
        $_.Extension -in @(".dart", ".md", ".yaml", ".yml")
    }

$changedFiles = 0
$totalReplacements = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $updated = $content
    $fileReplacementCount = 0

    foreach ($item in $replacements) {
        if ([string]::IsNullOrEmpty($item.Bad)) {
            continue
        }

        $count = 0
        $searchIndex = 0

        while ($true) {
            $foundIndex = $updated.IndexOf(
                $item.Bad,
                $searchIndex,
                [System.StringComparison]::Ordinal
            )

            if ($foundIndex -lt 0) {
                break
            }

            $count++
            $searchIndex = $foundIndex + $item.Bad.Length
        }

        if ($count -gt 0) {
            $updated = $updated.Replace($item.Bad, $item.Good)
            $fileReplacementCount += $count
            $totalReplacements += $count
        }
    }

    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText(
            $file.FullName,
            $updated,
            $utf8NoBom
        )

        $changedFiles++
        Write-Host ("Fixed {0} occurrence(s): {1}" -f $fileReplacementCount, $file.FullName)
    }
}

Write-Host ""
Write-Host "Encoding cleanup complete."
Write-Host ("Files changed: {0}" -f $changedFiles)
Write-Host ("Total replacements: {0}" -f $totalReplacements)
Write-Host ""
Write-Host "Next commands:"
Write-Host "  dart format lib test integration_test"
Write-Host "  flutter analyze"
Write-Host ""
Write-Host "Then restart the app:"
Write-Host "  flutter run -d windows"

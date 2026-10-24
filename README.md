# Multiplexado de Display de 7 Segmentos en VHDL (Práctica 5)

Proyecto en **VHDL** para la tarjeta **Digilent Nexys 2 (FPGA Spartan-3E)** que enciende los **4 dígitos del display de 7 segmentos al mismo tiempo** mediante multiplexado por división de tiempo. En el display se lee:

```
2 5 8 0
```

El repositorio incluye **dos versiones** del mismo circuito: una primera versión (`WorseVersionDisplayer`) y una versión mejorada y simplificada (`displayer2`).

## Tabla de contenido

- [Descripción general](#descripción-general)
- [Hardware objetivo](#hardware-objetivo)
- [Funcionamiento](#funcionamiento)
- [Las dos versiones](#las-dos-versiones)
- [Asignación de pines](#asignación-de-pines)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Cómo compilar y programar](#cómo-compilar-y-programar)
- [Autoría](#autoría)

## Descripción general

Los 4 dígitos de la Nexys 2 **comparten las 8 líneas de segmentos** (`a`–`g` y punto decimal) y cada dígito tiene su propio ánodo (`AN0`–`AN3`). Por eso no se pueden mostrar cuatro números distintos al mismo tiempo: hay que encender **un dígito a la vez** y cambiar de dígito tan rápido que el ojo percibe los cuatro encendidos. Esta práctica implementa ese multiplexado en un solo proceso VHDL, sin esquemáticos ni IP cores.

## Hardware objetivo

- **Tarjeta:** Digilent **Nexys 2**
- **FPGA:** Xilinx **Spartan-3E** `xc3s500e-5fg320`
- **Reloj:** 50 MHz (pin B8)
- **Herramienta:** Xilinx ISE Design Suite 14.7
- **Recursos usados:** 17 slices de 4,656 (menos del 1 %)

## Funcionamiento

```
 clk 50 MHz ──► divisor (cuenta 0…50 000) ──► cada ~1 ms ──► cnt (2 bits) ──┬──► disp(3:0)  (ánodo activo)
                                                                          └──► seg(7:0)   (patrón del dígito)
```

1. Una variable `df` cuenta ciclos de reloj de 0 a 50 000; al llegar al límite se reinicia. Esto genera un "tick" aproximadamente cada **1 ms** (≈ 1 kHz).
2. En cada tick se incrementa `cnt`, un contador de 2 bits que indica qué dígito se enciende.
3. Según `cnt` se activa un ánodo (activo en bajo) y se envía el patrón de segmentos (también activo en bajo, bit 0 = `a` … bit 7 = punto decimal):

| `cnt` | `disp` | Dígito | `seg` | Muestra |
|---|---|---|---|---|
| `00` | `1110` | AN0 (derecha) | `11000000` | **0** |
| `01` | `1101` | AN1 | `10000000` | **8** |
| `10` | `1011` | AN2 | `10010010` | **5** |
| `11` | `0111` | AN3 (izquierda) | `10100100` | **2** |

Cada dígito se refresca a ≈ 250 Hz, muy por encima de lo que el ojo puede notar, por lo que no hay parpadeo.

## Las dos versiones

| | `WorseVersionDisplayer.vhd` | `displayer2.vhd` |
|---|---|---|
| Flanco de reloj | bajada (`falling_edge`) | subida (`rising_edge`) |
| Lógica | Dos `case`: `cnt` → código one-hot `tmux` → segmentos | Un solo `case`: `cnt` → ánodo **y** segmentos |
| Variables inicializadas | No (`cnt` arranca indefinido en simulación) | Sí (`df := 0`, `cnt := "11"`) |
| Restricciones | `pines.ucf` | `pines2.ucf` |
| Bitstream | `bin/WorseVersionDisplayer.bit` | `bin/displayer2.bit` |

Ambas producen la misma salida en la tarjeta. `displayer2` es más limpia: elimina la variable intermedia `tmux`, usa el flanco de subida y tiene un estado inicial definido, lo que también hace que se comporte bien en simulación. El proyecto de ISE tiene configurado `WorseVersionDisplayer` como top.

## Asignación de pines

| Señal | Pin | Descripción |
|---|---|---|
| `clk` | B8 | Reloj de 50 MHz |
| `seg<0>` … `seg<6>` | L18, F18, D17, D16, G14, J17, H14 | Segmentos a–g |
| `seg<7>` | C17 | Punto decimal |
| `disp<0>` … `disp<3>` | F17, H17, C18, F15 | Ánodos AN0–AN3 |

## Estructura del repositorio

```
Practica5/
├── bin/
│   ├── WorseVersionDisplayer.bit   # Bitstream de la primera versión
│   └── displayer2.bit              # Bitstream de la versión mejorada
├── WorseVersionDisplayer.vhd       # Primera versión (top del proyecto)
├── displayer2.vhd                  # Versión mejorada
├── pines.ucf                       # Pines para WorseVersionDisplayer
├── pines2.ucf                      # Pines para displayer2 (mismos pines)
└── Practica5.xise                  # Proyecto de Xilinx ISE
```

## Cómo compilar y programar

**Solo programar:** carga cualquiera de los `.bit` de `bin/` con **Digilent Adept** o **iMPACT**:

```bash
djtgcfg prog -d Nexys2 -i 0 -f bin/displayer2.bit
```

**Compilar desde el código:**
1. Abre `Practica5.xise` en Xilinx ISE 14.7.
2. Ejecuta **Generate Programming File** (el top es `WorseVersionDisplayer`).
3. Para compilar la versión mejorada: *Project → Add Source* → `displayer2.vhd` y `pines2.ucf`, márcalo como *Top Module* y vuelve a generar el bitstream.

Verificado: el proyecto compila desde un clon limpio con ISE 14.7 y cumple todas las restricciones de tiempo.

## Autoría

El diseño, los esquemáticos y el código de esta práctica son obra de **Esteban Santiago**. La documentación (este README) se redactó con ayuda de Claude (IA).

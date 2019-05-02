from PIL import Image
import matplotlib.pyplot as plt
import numpy


class ImageObject:
    def __init__(self, key, array_img, mode):
        self._key = key  # Endereco da imagen no dicionario.
        self._pil_img = Image.fromarray(array_img, mode)  # Imagem no formato da biblioteca PIL.
        self._array_img = array_img  # Imagem como um array.
        self._mode = mode  # Modo de cor da imagem.
        self._channels = array_img[0][0].size
        self._color_deep = 8

    def get_pil_img(self):
        return self._pil_img

    def get_array_img(self):
        return self._array_img

    def get_mode(self):
        return self._mode

    def get_channels(self):
        return self._channels

    def set_pil_img(self, img):
        self._pil_img = img
        self._array_img = numpy.array(img, numpy.uint8)

    def set_array_img(self, array):
        self._array_img = array
        self._pil_img = Image.fromarray(array)


# Armazena todas as imagens.
images_dictionary = {}

# region ---------------- FUNCIONALIDADES BASICAS ----------------


# Converte uma imagen RBG em Tons de Cinza usado a media ou combinacao linear.
def rgb_to_grey(key, mode):
    print('Convertendo imagem para tons de cinza...')
    global images_dictionary

    try:
        img = images_dictionary[key].get_array_img()
    except:
        print("Imagem nao encontrada.")
        return

    width, height = images_dictionary[key].get_pil_img().size
    grey_array = numpy.zeros((height, width), numpy.uint8)

    a = 0.26
    b = 0.68
    c = 0.06

    for i in range(0, height):
        for j in range(0, width):
            if mode == '0':
                med = numpy.uint8(numpy.average(img[i][j]))
            else:
                med = numpy.uint8(a*img[i][j][0] + b*img[i][j][1] + c*img[i][j][2])

            grey_array[i][j] = med

    new_key = input("Salvar imagem como: \n")
    images_dictionary[new_key] = ImageObject(new_key, grey_array, "L")

    print("Conversao completa.")


def grey_to_rgb(key):
    print("Convertendo TC para RGB...")
    global images_dictionary
    try:
        img = images_dictionary[key].get_array_img()
    except:
        print("Imagem nao encontrada.")
        return
    width, height = images_dictionary[key].get_pil_img().size
    rgb_array = numpy.zeros((height, width, 3), numpy.uint8)

    for i in range(0, height):
        for j in range(0, width):
            rgb_array[i][j][0] = img[i][j]
            rgb_array[i][j][1] = img[i][j]
            rgb_array[i][j][2] = img[i][j]

    new_key = input("Salvar imagem como: \n")
    images_dictionary[new_key] = ImageObject(new_key, rgb_array, "RGB")

    print("Conversao completa.")


# Funcao privada para retornar uma imagem em tc.
def rgb_to_gray_advanced(key, mode):
    global images_dictionary
    img_array = images_dictionary[key].get_array_img()
    width, height = images_dictionary[key].get_pil_img().size
    grey_array = numpy.zeros((width, height), numpy.uint8)
    a = 0.26
    b = 0.68
    c = 0.06

    for i in range(0, width):
        for j in range(0, height):
            if mode == 0:
                med = numpy.uint8(numpy.average(img_array[i][j]))
            else:
                med = numpy.uint8(a * img_array[i][j][0] + b * img_array[i][j][1] + c * img_array[i][j][2])

            grey_array[i][j] = med

    return grey_array


# Calcula e imprime o MSE e o SNR
def calculate_mse_and_snr(key1, key2):
    print('Calculando MSE e SNR...')
    img1_array = rgb_to_gray_advanced(key1, 1)
    img2_array = rgb_to_gray_advanced(key2, 1)
    width, height = images_dictionary[key1].get_pil_img().size
    s = 0

    for i in range(0, width):
        for j in range(0, height):
            dif = img1_array[i][j] - img2_array[i][j]
            s += dif*dif

    mse = s/(width*height)
    print("MSE: ", mse)

    if mse != 0:
        snr = -10*numpy.log10(mse/(255*255))
        print("SNR: ", snr)

# endregion


# region ------------------------ EXIBICAO -----------------------


# Exibe duas imagens lado a lado para comparacao.
def show_image_side_by_side(key1, key2):
    global images_dictionary

    plt.figure()
    plt.gray()
    plt.subplot(121)
    plt.axis('off')
    try:
        plt.title(key1)
        plt.imshow(images_dictionary[key1].get_array_img())
    except:
        print("Imagem nao encontrada.")
        return
    plt.subplot(122)
    plt.axis('off')
    try:
        plt.title(key2)
        plt.imshow(images_dictionary[key2].get_array_img())
    except:
        print("Imagem nao encontrada.")
        return
    print("Para continuar feche a janela.")
    plt.show()


# Exibe todas as imagens no dicinario.
def show_all_images():
    print("Para continuar feche a janela.")
    global images_dictionary
    ncols = len(images_dictionary)
    plt.figure()
    plt.gray()
    i = 1
    for k in images_dictionary:
        plt.subplot(1, ncols, i)
        plt.axis('off')
        plt.title(k)
        plt.imshow(images_dictionary[k].get_array_img())
        i += 1
    plt.show()


# Exibe a imagem ativa.
def show_image(key):
    # fig = plt.figure()
    plt.title(key)
    plt.axis('off')
    plt.gray()
    try:
        plt.imshow(images_dictionary[key].get_array_img())
    except:
        print("Imagem nao encontrada.")
        return
    print("Para continuar feche a janela.")
    plt.show()


# Imprime a key de todas as imagens no dicionario.
def images_in_edit():
    for k in images_dictionary:
        print(k)

# endregion


# region ------------------- OPERACOES EM DISCO ------------------


# Abre uma imagem dado seu endereco.
def open_image(image_path):
    key = input("Carregar imagem como: ")

    print("Carregando ", image_path, "...")

    global images_dictionary

    try:
        img = Image.open(image_path)
    except:
        print("Arquivo nao encontrado.")
        return

    images_dictionary[key] = ImageObject(key, numpy.array(img, numpy.uint8), img.mode)

    print("Imagem carregada com sucesso.")


# Salva uma imagem com o nome e formatos informados.
def save_image(key, save_name):
    print("Salvando imagem...")
    try:
        images_dictionary[key].get_pil_img().save(save_name)
    except:
        print("Não foi possiel salvar a imagem.")
        return
    print("Imagem salva.")

# endregion


# region --------------------- TRANSFORMACOES --------------------


def gama_correction(key, gamma):
    print("Aplicando correção gamma...")
    global images_dictionary
    try:
        image_object = images_dictionary[key]
    except:
        print("Imagem não encontrada.")
        return
    orig_array = image_object.get_array_img()
    width, height = image_object.get_pil_img().size
    channels = image_object.get_channels()
    if channels > 1:
        correc_array = numpy.zeros((height, width, channels), numpy.uint8)
    else:
        correc_array = numpy.zeros((height, width), numpy.uint8)
    y = 1/gamma

    for i in range(0, height):
        for j in range(0, width):
                correc_array[i][j] = 255 * pow(orig_array[i][j] / 255, y)

    new_key = input("Salvar imagem como: \n")
    images_dictionary[new_key] = ImageObject(new_key, correc_array, image_object.get_mode())
    print("Completo.")


def histogram_equalization(key):
    print("Realizando equalização de histograma...")
    global images_dictionary
    img_array = images_dictionary[key].get_array_img()
    width, height = images_dictionary[key].get_pil_img().size
    channels = images_dictionary[key].get_channels()
    total_px = width*height
    sum = 0

    # Cada posição corresponde a uma itensidade e o valor armazendo é o num de pixels.
    if channels > 1:
        px_inten_count = numpy.zeros((256, channels), int)
        norm_array = numpy.zeros((height, width, channels), numpy.uint8)
        for i in range(0, height):
            for j in range(0, width):
                for k in range(0, channels):
                    px_inten_count[img_array[i][j][k]][k] += 1

        print(px_inten_count)

        for i in range(0, height):
            for j in range(0, width):
                for k in range(0, channels):
                    for w in range(0, img_array[i][j][k]):
                        sum += px_inten_count[w][k] / total_px
                    norm_array[i][j][k] = numpy.floor(255 * sum)
                    sum = 0
    else:
        px_inten_count = numpy.zeros(256, int)
        norm_array = numpy.zeros((height, width), numpy.uint8)

        for i in range(0, height):
            for j in range(0, width):
                px_inten_count[img_array[i][j]] += 1

        print(px_inten_count)

        for i in range(0, height):
            for j in range(0, width):
                for k in range(0, img_array[i][j]):
                    sum += px_inten_count[k] / total_px
                norm_array[i][j] = numpy.floor(255 * sum)
                sum = 0

    new_key = input("Salvar imagem como: \n")
    images_dictionary[new_key] = ImageObject(new_key, norm_array, images_dictionary[key].get_mode())


def binarize(key, mode, t):
    global images_dictionary
    img = images_dictionary[key].get_array_img()
    width, height = images_dictionary[key].get_pil_img().size
    channels = images_dictionary[key].get_channels()
    bin_img = numpy.zeros((width, height))
    sum = 0
    if mode == '1':
        for i in range(0, height):
            for j in range(0, width):
                for k in range(0, channels):
                    sum += img[i][j][k]
                if sum/channels >= t:
                    bin_img[i][j] = 1
                else:
                    bin_img[i][j] = 0
                sum = 0

    new_key = input("Salvar imagem como: \n")
    images_dictionary[new_key] = ImageObject(new_key, bin_img, '1')


def quantize():
    return


# endregion

def main():
    while True:
        print('-----------------------------------------------------------------\n'
              '                               MENU\n'
              '-----------------------------------------------------------------\n')

        op = input('1-Abrir imagem                 2-Salvar imagem\n'
                   '3-Exibir uma imagem            4-Exibir 2 imagens\n'
                   '5-Exibir todas as imagens      6-Exibir imagens na memoria\n'
                   '7-Converter RGB para TC        8-Converter TC para RGB\n'
                   '9-Calcular MSE e SNR           10-Aplicar correção gamma\n'
                   '11-Equalização de histograma   12-Binarizar imagem\n'
                   '13-Quanizar imagem\n'
                   '->')

        if op == '1':
            imgpt = input('Image path\n->')
            if imgpt == '':
                imgpt = 'lena.png'
            open_image(imgpt)
        if op == '2':
            key = input("Image: ")
            path = input("Path: ")
            save_image(key, path)
        if op == '3':
            key = input("Image: ")
            show_image(key)
        if op == '4':
            key1 = input("Image 1: ")
            key2 = input("Image 2: ")
            show_image_side_by_side(key1, key2)
        if op == '5':
            show_all_images()
        if op == '6':
            images_in_edit()
        if op == '7':
            key = input("Key: ")
            md = input("Mode: ")
            rgb_to_grey(key, md)
        if op == '8':
            key = input("Image: ")
            grey_to_rgb(key)
        if op == '9':
            imgpt1 = input('Image path 1: ')
            imgpt2 = input('Image path 2: ')
            calculate_mse_and_snr(imgpt1, imgpt2)
        if op == '10':
            key = input("Image: ")
            gamma = float(input("Gamma: "))
            gama_correction(key, gamma)
        if op == '11':
            key = input("Image: ")
            histogram_equalization(key)
        if op == '12':
            key = input("Image: ")
            mode = input("Mode: ")
            t = int(input("T: "))
            binarize(key, mode, t)
        if op == '13':
            return


if __name__ == "__main__":
    main()

//
//  Labels.swift
//  Flan
//
//  Created by Вадим on 07.09.2021.
//

import Foundation

enum Labels {
    enum StartVC {
        static let textForOfflineMode = "Оффлайн режим",
                   textForRepeatConnection = "Повторить загрузку",
                   networkAlertTitle = "Упс...",
                   networkAlerMessage = "Пожалуйста, проверьте cоединение с Интернетом",
                   textLabel = "Вы можете включить оффлайн режим, при этом отобразятся последние загруженные данные, но они могут быть неактуальны"
    }
    
    enum MenuVC {
        static let searchPlaceholder = "Введите название",
                   emptyViewTitle = "Ошибка сервера",
                   emptyViewMessage = "Не удалось загрузить данные. Проводятся технические работы",
                   emptyFilteringViewTitle = "Ничего не найдено...",
                   emptyFilteringViewMessage = "Попробуйте ввести что-нибудь другое"
    }
    
    enum FavoriteVC {
        static let emptyViewTitle = "Пусто",
                   emptyViewMessage = "Чтобы добавить свою вкусняшку в избранное нажмите на иконку сердечка"
    }
    
    enum ListVC {
        static let popoverText = "В этом поле указывается приблизительная сумма, она не учитывает фактический вес всех позиций, цену упаковочных изделий и т.п. Эта сумма отображается исключительно в ознакомительных целях.",
                   emptyViewTitle = "Пусто",
                   emptyViewMessage = "Добавьте что-нибудь в список",
                   firstSectionTitle = "Купить",
                   secondSectionTitle = "Куплено"
    }
    
    enum CustomizedCVC {
        static let popoverText = "Здесь находится лишь небольшая часть наших работ, но мы надеемся, что одна из них поможет вам найти идею для индивидуального заказа.",
                   emptyViewTitle = "Ошибка сервера",
                   emptyViewMessage = "Не удалось загрузить данные. Проводятся технические работы"
    }
    
    enum CustomizedDetailVC {
        static let permissionDeniedAlertTitle = "Запись изображения в галерею недоступна",
                   permissionDeniedAlertMessage = "Вероятно, вы запретили приложению добавлять изображения в ваши фото. Если вы сделали это случайно или передумали, вы можете перейти в настройки приложения и разрешить доступ к фото."
    }
    
    enum ContactsVC {
        static let flanEmail = "PekarnyaFlanApp@gmail.com",
                   emptyViewTitle = "Ошибка сервера",
                   emptyViewMessage = "Не удалось загрузить данные. Проводятся технические работы",
                   instagramUsername = "pekarnya_flan",
                   sendEmailSubject = "Идея для приложения Флан",
                   sendEmailMessageBody = "Напишите здесь Вашу идею или предложение по улучшению приложения Флан",
                   showAlertTitle = "Ошибка",
                   showAlertMessage = "Не найден аккаунт вашей почты, но вы можете другим способом направить свое письмо на email: \(flanEmail)"
    }
}

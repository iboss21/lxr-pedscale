--[[
    ██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
                                                                                                   
    🐺 LXR Ped Scale - Locale / Language Configuration
    
    Multi-language support for the character customization system.
    Add your language translations here.
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LOCALE CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════════

Locale = {}

-- Helper function to get localized string
function Locale:Get(key)
    local lang = Config.Lang or 'en'
    if self[lang] and self[lang][key] then
        return self[lang][key]
    elseif self.en and self.en[key] then
        return self.en[key]
    else
        return 'Missing translation: ' .. key
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ENGLISH TRANSLATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

Locale.en = {
    -- Interaction
    interact_npc = 'Press ~o~[G]~w~ to interact with %s',
    interact_cancel = 'Press ~e~[X]~w~ to cancel',
    
    -- Menu Headers
    menu_main = 'Character Customization',
    menu_name_change = 'Change Name',
    menu_scale_change = 'Adjust Height',
    menu_choose_option = 'Choose Customization',
    
    -- Menu Options
    option_change_name = 'Change Name ($%s)',
    option_change_scale = 'Adjust Height ($%s)',
    option_firstname = 'Change Firstname ($%s)',
    option_lastname = 'Change Lastname ($%s)',
    option_both_names = 'Change Both Names ($%s)',
    option_increase_scale = 'Increase Height (+1%)',
    option_decrease_scale = 'Decrease Height (-1%)',
    option_confirm_scale = 'Confirm Height',
    option_cancel = 'Cancel',
    
    -- Input Labels
    input_firstname = 'Enter new firstname',
    input_lastname = 'Enter new lastname',
    
    -- Success Messages
    success_name_changed = 'Name changed successfully to %s %s',
    success_firstname_changed = 'Firstname changed successfully to %s',
    success_lastname_changed = 'Lastname changed successfully to %s',
    success_scale_changed = 'Height adjusted successfully to %.2f',
    
    -- Error Messages
    error_insufficient_funds = 'Insufficient funds. Required: $%s',
    error_invalid_name = 'Invalid name. Please use only letters (2-20 characters)',
    error_forbidden_name = 'This name is not allowed',
    error_profanity_detected = 'Inappropriate language detected',
    error_cooldown_active = 'Please wait %s before making changes again',
    error_scale_min = 'Minimum height reached (%.2f)',
    error_scale_max = 'Maximum height reached (%.2f)',
    error_too_far = 'You are too far from the NPC',
    error_generic = 'An error occurred. Please try again',
    error_cancelled = 'Action cancelled',
    error_no_permission = 'You do not have permission to use this',
    
    -- Info Messages
    info_current_scale = 'Current height: %.2f',
    info_admin_bypass = 'Admin bypass - No charge',
    info_processing = 'Processing...',
    
    -- Cooldown
    cooldown_minutes = '%d minutes',
    cooldown_seconds = '%d seconds',
    
    -- Discord Logs
    discord_name_change = '**Name Changed**\nPlayer: %s\nOld: %s %s\nNew: %s %s\nCost: $%s',
    discord_scale_change = '**Height Adjusted**\nPlayer: %s\nOld: %.2f\nNew: %.2f\nCost: $%s',
    discord_admin_bypass = '**Admin Bypass**\nAdmin: %s\nAction: %s'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- GEORGIAN TRANSLATIONS (ქართული)
-- ═══════════════════════════════════════════════════════════════════════════════

Locale.ge = {
    -- Interaction
    interact_npc = 'დააჭირე ~o~[G]~w~ ურთიერთობისთვის %s-თან',
    interact_cancel = 'დააჭირე ~e~[X]~w~ გასაუქმებლად',
    
    -- Menu Headers
    menu_main = 'პერსონაჟის კასტომიზაცია',
    menu_name_change = 'სახელის შეცვლა',
    menu_scale_change = 'სიმაღლის რეგულირება',
    menu_choose_option = 'აირჩიე კასტომიზაცია',
    
    -- Menu Options
    option_change_name = 'სახელის შეცვლა ($%s)',
    option_change_scale = 'სიმაღლის რეგულირება ($%s)',
    option_firstname = 'სახელის შეცვლა ($%s)',
    option_lastname = 'გვარის შეცვლა ($%s)',
    option_both_names = 'ორივეს შეცვლა ($%s)',
    option_increase_scale = 'სიმაღლის გაზრდა (+1%)',
    option_decrease_scale = 'სიმაღლის შემცირება (-1%)',
    option_confirm_scale = 'სიმაღლის დადასტურება',
    option_cancel = 'გაუქმება',
    
    -- Input Labels
    input_firstname = 'შეიყვანე ახალი სახელი',
    input_lastname = 'შეიყვანე ახალი გვარი',
    
    -- Success Messages
    success_name_changed = 'სახელი წარმატებით შეიცვალა %s %s-ზე',
    success_firstname_changed = 'სახელი წარმატებით შეიცვალა %s-ზე',
    success_lastname_changed = 'გვარი წარმატებით შეიცვალა %s-ზე',
    success_scale_changed = 'სიმაღლე წარმატებით შეიცვალა %.2f-ზე',
    
    -- Error Messages
    error_insufficient_funds = 'არასაკმარისი თანხა. საჭიროა: $%s',
    error_invalid_name = 'არასწორი სახელი. გამოიყენე მხოლოდ ასოები (2-20 სიმბოლო)',
    error_forbidden_name = 'ეს სახელი დაუშვებელია',
    error_profanity_detected = 'აღმოჩენილია შეუფერებელი სიტყვები',
    error_cooldown_active = 'გთხოვთ დაელოდო %s ხელახლა ცვლილებების შესატანად',
    error_scale_min = 'მინიმალური სიმაღლე მიღწეულია (%.2f)',
    error_scale_max = 'მაქსიმალური სიმაღლე მიღწეულია (%.2f)',
    error_too_far = 'ძალიან შორს ხარ NPC-სგან',
    error_generic = 'დაფიქსირდა შეცდომა. გთხოვთ ცადოთ ხელახლა',
    error_cancelled = 'მოქმედება გაუქმდა',
    error_no_permission = 'არ გაქვს ამის გამოყენების უფლება',
    
    -- Info Messages
    info_current_scale = 'ამჟამინდელი სიმაღლე: %.2f',
    info_admin_bypass = 'ადმინის უფლება - უფასო',
    info_processing = 'მუშავდება...',
    
    -- Cooldown
    cooldown_minutes = '%d წუთი',
    cooldown_seconds = '%d წამი',
    
    -- Discord Logs
    discord_name_change = '**სახელი შეიცვალა**\nმოთამაშე: %s\nძველი: %s %s\nახალი: %s %s\nღირებულება: $%s',
    discord_scale_change = '**სიმაღლე შეიცვალა**\nმოთამაშე: %s\nძველი: %.2f\nახალი: %.2f\nღირებულება: $%s',
    discord_admin_bypass = '**ადმინის უფლება**\nადმინი: %s\nმოქმედება: %s'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SPANISH TRANSLATIONS (Español)
-- ═══════════════════════════════════════════════════════════════════════════════

Locale.es = {
    interact_npc = 'Presiona ~o~[G]~w~ para interactuar con %s',
    interact_cancel = 'Presiona ~e~[X]~w~ para cancelar',
    menu_main = 'Personalización de Personaje',
    menu_name_change = 'Cambiar Nombre',
    menu_scale_change = 'Ajustar Altura',
    menu_choose_option = 'Elegir Personalización',
    option_change_name = 'Cambiar Nombre ($%s)',
    option_change_scale = 'Ajustar Altura ($%s)',
    option_firstname = 'Cambiar Nombre ($%s)',
    option_lastname = 'Cambiar Apellido ($%s)',
    option_both_names = 'Cambiar Ambos ($%s)',
    option_increase_scale = 'Aumentar Altura (+1%)',
    option_decrease_scale = 'Disminuir Altura (-1%)',
    option_confirm_scale = 'Confirmar Altura',
    option_cancel = 'Cancelar',
    input_firstname = 'Introduce nuevo nombre',
    input_lastname = 'Introduce nuevo apellido',
    success_name_changed = 'Nombre cambiado exitosamente a %s %s',
    success_firstname_changed = 'Nombre cambiado exitosamente a %s',
    success_lastname_changed = 'Apellido cambiado exitosamente a %s',
    success_scale_changed = 'Altura ajustada exitosamente a %.2f',
    error_insufficient_funds = 'Fondos insuficientes. Requerido: $%s',
    error_invalid_name = 'Nombre inválido. Usa solo letras (2-20 caracteres)',
    error_forbidden_name = 'Este nombre no está permitido',
    error_profanity_detected = 'Lenguaje inapropiado detectado',
    error_cooldown_active = 'Por favor espera %s antes de hacer cambios nuevamente',
    error_scale_min = 'Altura mínima alcanzada (%.2f)',
    error_scale_max = 'Altura máxima alcanzada (%.2f)',
    error_too_far = 'Estás demasiado lejos del NPC',
    error_generic = 'Ocurrió un error. Inténtalo de nuevo',
    error_cancelled = 'Acción cancelada',
    error_no_permission = 'No tienes permiso para usar esto',
    info_current_scale = 'Altura actual: %.2f',
    info_admin_bypass = 'Bypass de administrador - Sin cargo',
    info_processing = 'Procesando...',
    cooldown_minutes = '%d minutos',
    cooldown_seconds = '%d segundos'
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- FRENCH TRANSLATIONS (Français)
-- ═══════════════════════════════════════════════════════════════════════════════

Locale.fr = {
    interact_npc = 'Appuyez sur ~o~[G]~w~ pour interagir avec %s',
    interact_cancel = 'Appuyez sur ~e~[X]~w~ pour annuler',
    menu_main = 'Personnalisation du Personnage',
    menu_name_change = 'Changer de Nom',
    menu_scale_change = 'Ajuster la Taille',
    menu_choose_option = 'Choisir la Personnalisation',
    option_change_name = 'Changer de Nom ($%s)',
    option_change_scale = 'Ajuster la Taille ($%s)',
    option_firstname = 'Changer le Prénom ($%s)',
    option_lastname = 'Changer le Nom de Famille ($%s)',
    option_both_names = 'Changer les Deux ($%s)',
    option_increase_scale = 'Augmenter la Taille (+1%)',
    option_decrease_scale = 'Diminuer la Taille (-1%)',
    option_confirm_scale = 'Confirmer la Taille',
    option_cancel = 'Annuler',
    input_firstname = 'Entrez le nouveau prénom',
    input_lastname = 'Entrez le nouveau nom de famille',
    success_name_changed = 'Nom changé avec succès en %s %s',
    success_firstname_changed = 'Prénom changé avec succès en %s',
    success_lastname_changed = 'Nom de famille changé avec succès en %s',
    success_scale_changed = 'Taille ajustée avec succès à %.2f',
    error_insufficient_funds = 'Fonds insuffisants. Requis: $%s',
    error_invalid_name = 'Nom invalide. Utilisez uniquement des lettres (2-20 caractères)',
    error_forbidden_name = 'Ce nom n\'est pas autorisé',
    error_profanity_detected = 'Langage inapproprié détecté',
    error_cooldown_active = 'Veuillez attendre %s avant de faire des changements',
    error_scale_min = 'Taille minimale atteinte (%.2f)',
    error_scale_max = 'Taille maximale atteinte (%.2f)',
    error_too_far = 'Vous êtes trop loin du PNJ',
    error_generic = 'Une erreur s\'est produite. Réessayez',
    error_cancelled = 'Action annulée',
    error_no_permission = 'Vous n\'avez pas la permission d\'utiliser ceci',
    info_current_scale = 'Taille actuelle: %.2f',
    info_admin_bypass = 'Contournement admin - Gratuit',
    info_processing = 'Traitement...',
    cooldown_minutes = '%d minutes',
    cooldown_seconds = '%d secondes'
}

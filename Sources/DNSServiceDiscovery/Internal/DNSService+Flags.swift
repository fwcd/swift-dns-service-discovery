import CDNSSD

extension DNSService {
    // Based on https://github.com/nallick/dns_sd/blob/9e9841c131cc1357fc63b69ff75d6d91e45b8429/Sources/dns_sd/Flags.swift
    // MIT-licensed (Copyright (c) 2019 Purgatory Design)

    struct Flags: OptionSet, Hashable {
        let rawValue: CDNSSD.DNSServiceFlags

        static let moreComing           = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsMoreComing))
        static let add                  = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsAdd))
        static let `default`            = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsDefault))
        static let noAutoRename         = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsNoAutoRename))
        static let shared               = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsShared))
        static let unique               = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsUnique))
        static let browseDomains        = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsBrowseDomains))
        static let registrationDomains  = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsRegistrationDomains))
        static let longLivedQuery       = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsLongLivedQuery))
        static let allowRemoteQuery     = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsAllowRemoteQuery))
        static let forceMulticast       = Self(rawValue: DNSServiceFlags(kDNSServiceFlagsForceMulticast))
    }
}

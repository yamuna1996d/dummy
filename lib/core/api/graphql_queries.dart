/// Centralized GraphQL query and mutation documents.
///
/// These are executed locally against bundled JSON data (see
/// GraphQLJsonExecutor) rather than sent over the network, but are kept in
/// GraphQL document form for readability and so the document text can be
/// used as a routing key.
abstract final class GraphQLQueries {
  // Caregiver profile (single record, used by auth + profile)
  static const String getUser = r'''
    query GetUser($id: ID!) {
      user(id: $id) {
        id
        name
        username
        email
        phone
        avatarUrl
      }
    }
  ''';

  // Children
  static const String getChildren = r'''
    query GetChildren($options: PageQueryOptions) {
      children(options: $options) {
        data {
          id
          name
          age
          gender
          guardianName
          description
          bloodGroup
          weightKg
          allergyName
          allergyNote
          heightPercentile
          nextAppointmentTitle
          nextAppointmentDate
          nextAppointmentTime
          nextAppointmentLocation
          nextAppointmentClinicPhone
        }
        meta {
          totalCount
        }
      }
    }
  ''';

  static const String getChild = r'''
    query GetChild($id: ID!) {
      child(id: $id) {
        id
        name
        age
        gender
        guardianName
        description
        bloodGroup
        weightKg
        allergyName
        allergyNote
        heightPercentile
        nextAppointmentTitle
        nextAppointmentDate
        nextAppointmentTime
        nextAppointmentLocation
        nextAppointmentClinicPhone
      }
    }
  ''';

  static const String createChild = r'''
    mutation CreateChild($input: CreateChildInput!) {
      createChild(input: $input) {
        id
        name
        age
        gender
        guardianName
        description
        bloodGroup
        weightKg
        allergyName
        allergyNote
        heightPercentile
        nextAppointmentTitle
        nextAppointmentDate
        nextAppointmentTime
        nextAppointmentLocation
        nextAppointmentClinicPhone
      }
    }
  ''';

  static const String updateChild = r'''
    mutation UpdateChild($id: ID!, $input: UpdateChildInput!) {
      updateChild(id: $id, input: $input) {
        id
        name
        age
        gender
        guardianName
        description
        bloodGroup
        weightKg
        allergyName
        allergyNote
        heightPercentile
        nextAppointmentTitle
        nextAppointmentDate
        nextAppointmentTime
        nextAppointmentLocation
        nextAppointmentClinicPhone
      }
    }
  ''';

  static const String deleteChild = r'''
    mutation DeleteChild($id: ID!) {
      deleteChild(id: $id)
    }
  ''';

  // Medications
  static const String getMedications = r'''
    query GetMedications($options: PageQueryOptions) {
      medications(options: $options) {
        data {
          id
          name
          dosage
          frequency
          isActive
          childId
          notes
          startDate
          endDate
        }
        meta {
          totalCount
        }
      }
    }
  ''';

  static const String createMedication = r'''
    mutation CreateMedication($input: CreateMedicationInput!) {
      createMedication(input: $input) {
        id
        name
        dosage
        frequency
        isActive
        childId
        notes
        startDate
        endDate
      }
    }
  ''';

  static const String updateMedication = r'''
    mutation UpdateMedication($id: ID!, $input: UpdateMedicationInput!) {
      updateMedication(id: $id, input: $input) {
        id
        name
        dosage
        frequency
        isActive
        childId
        notes
        startDate
        endDate
      }
    }
  ''';

  static const String deleteMedication = r'''
    mutation DeleteMedication($id: ID!) {
      deleteMedication(id: $id)
    }
  ''';
}
